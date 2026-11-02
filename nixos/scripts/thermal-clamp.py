#!/usr/bin/env python3
"""Surface heat-soak power governor.

Why this exists: Surface Laptop 4 PROCHOT lockouts (all cores pinned to
200 MHz for ~60 s) were NOT preceded by a hot die (77-81 C at onset).
They followed 90-240 s of sustained 20-25 W package power, i.e. the
chassis soaking up heat. So instead of reacting to die temperature,
this tracks a slow average of package power ("heat") and shapes PL1
from it:

  * Bursty / light loads never get clamped; PL2 stays high.
  * PL1 stays at P_FULL until heat nears the budget, then slides down
    so that sustained power settles at BUDGET (a true fixed point).
  * If a lockout happens anyway, the budget is lowered (derate),
    persisted across reboots, and recovers very slowly.
  * Die temperature is only a fast safety net (PL2 -> PL1 briefly).
"""
import glob
import json
import math
import os
import signal
import sys
import time

RAPL = "/sys/class/powercap/intel-rapl:0"
PL1_F = RAPL + "/constraint_0_power_limit_uw"
PL2_F = RAPL + "/constraint_1_power_limit_uw"
ENERGY_F = RAPL + "/energy_uj"
RANGE_F = RAPL + "/max_energy_range_uj"


def cfg_from_env():
    def f(name, default):
        return float(os.environ.get(name, default))

    return {
        "tau": f("CLAMP_TAU_S", 60),            # heat-soak time constant
        "budget": f("CLAMP_BUDGET_W", 16),      # sustainable average power
        "knee": f("CLAMP_KNEE_W", 3),           # taper starts budget-knee
        "floor_drop": f("CLAMP_FLOOR_DROP_W", 2),  # lowest PL1 = budget-this
        "p_full": f("CLAMP_PL1_FULL_W", 25.5),
        "p2": f("CLAMP_PL2_W", 40),
        "panic_c": f("CLAMP_DIE_PANIC_C", 95),
        "panic_hold": f("CLAMP_DIE_HOLD_S", 10),
        "lock_mhz": f("CLAMP_LOCKOUT_MHZ", 250),
        "derate_step": f("CLAMP_DERATE_STEP_W", 1.5),
        "derate_max": f("CLAMP_DERATE_MAX_W", 5),
        "recover_s": f("CLAMP_RECOVER_S", 4 * 3600),
        "recover_step": f("CLAMP_RECOVER_STEP_W", 0.5),
    }


class Governor:
    """Pure logic (no I/O) so it can be replayed against captured data."""

    def __init__(self, cfg, derate=0.0):
        self.c = cfg
        self.derate = derate
        self.heat = None

    def observe(self, power_w, dt):
        if self.heat is None:
            self.heat = power_w
            return
        a = 1.0 - math.exp(-dt / self.c["tau"])
        self.heat += a * (power_w - self.heat)

    @property
    def budget(self):
        return self.c["budget"] - self.derate

    def pl1(self):
        full = self.c["p_full"]
        b = self.budget
        if self.heat is None or b >= full:
            return full
        slope = (full - b) / self.c["knee"]
        # equals `full` at heat = b - knee, and exactly `b` at heat = b,
        # so sustained power converges to the budget without oscillating.
        want = b + (b - self.heat) * slope
        return max(b - self.c["floor_drop"], min(full, want))


def read(path):
    with open(path) as fh:
        return fh.read().strip()


def read_int(path):
    return int(read(path))


def find_pkg_temp():
    for zone in sorted(glob.glob("/sys/class/thermal/thermal_zone*")):
        try:
            if read(zone + "/type") == "x86_pkg_temp":
                return zone + "/temp"
        except OSError:
            pass
    return None


def read_freqs_mhz():
    out = []
    for p in sorted(glob.glob("/sys/devices/system/cpu/cpufreq/policy*")):
        for name in ("scaling_cur_freq", "cpuinfo_cur_freq"):
            try:
                out.append(read_int(p + "/" + name) / 1000.0)
                break
            except (OSError, ValueError):
                continue
    return out


def apply_limit(path, watts):
    target = int(watts * 1_000_000)
    try:
        cur = read_int(path)
    except OSError:
        return
    # tolerate RAPL unit rounding; also re-asserts if thermald/ppd rewrote it
    if abs(cur - target) > 150_000:
        with open(path, "w") as fh:
            fh.write(str(target))


def load_derate(state_file, cap):
    try:
        with open(state_file) as fh:
            return min(cap, max(0.0, float(json.load(fh)["derate"])))
    except (OSError, ValueError, KeyError):
        return 0.0


def save_derate(state_file, derate):
    try:
        with open(state_file, "w") as fh:
            json.dump({"derate": derate}, fh)
    except OSError:
        pass


def main():
    cfg = cfg_from_env()
    for p in (PL1_F, PL2_F, ENERGY_F, RANGE_F):
        if not os.access(p, os.R_OK):
            sys.exit("cannot read " + p)
    if not (os.access(PL1_F, os.W_OK) and os.access(PL2_F, os.W_OK)):
        sys.exit("cannot write RAPL limits")

    temp_f = find_pkg_temp()
    state_dir = os.environ.get("STATE_DIRECTORY", "/var/lib/surface-thermal-clamp")
    state_file = os.path.join(state_dir, "state.json")
    gov = Governor(cfg, load_derate(state_file, cfg["derate_max"]))

    def restore_and_exit(*_):
        apply_limit(PL1_F, cfg["p_full"])
        apply_limit(PL2_F, cfg["p2"])
        sys.exit(0)

    signal.signal(signal.SIGTERM, restore_and_exit)

    energy_range = read_int(RANGE_F)
    last_e, last_t = read_int(ENERGY_F), time.monotonic()
    low_run = 0
    in_lockout = False
    panic_until = 0.0
    last_logged = None
    derate_changed = time.monotonic()

    apply_limit(PL1_F, cfg["p_full"])
    apply_limit(PL2_F, cfg["p2"])
    print("heat-soak governor started: budget %.1f W (derate %.1f), tau %.0f s"
          % (cfg["budget"], gov.derate, cfg["tau"]), flush=True)

    while True:
        time.sleep(1)
        now = time.monotonic()
        e = read_int(ENERGY_F)
        de = e - last_e if e >= last_e else e + energy_range - last_e
        dt = now - last_t
        last_e, last_t = e, now
        if dt <= 0:
            continue
        power = de / dt / 1e6
        gov.observe(power, dt)

        # --- PROCHOT lockout detection: every core pinned below min freq
        freqs = read_freqs_mhz()
        locked = bool(freqs) and max(freqs) <= cfg["lock_mhz"]
        low_run = low_run + 1 if locked else 0
        if low_run >= 2 and not in_lockout:
            in_lockout = True
            gov.derate = min(cfg["derate_max"], gov.derate + cfg["derate_step"])
            derate_changed = now
            save_derate(state_file, gov.derate)
            print("LOCKOUT detected: heat %.1f W, power %.1f W -> budget now %.1f W"
                  % (gov.heat, power, gov.budget), flush=True)
        elif in_lockout and freqs and max(freqs) > 2 * cfg["lock_mhz"]:
            in_lockout = False

        # --- very slow recovery of the derate (each probe may cost a lockout)
        if gov.derate > 0 and now - derate_changed >= cfg["recover_s"]:
            gov.derate = max(0.0, gov.derate - cfg["recover_step"])
            derate_changed = now
            save_derate(state_file, gov.derate)

        pl1 = gov.pl1()
        pl2 = cfg["p2"]

        # --- fast die-temperature safety net
        if temp_f:
            try:
                if read_int(temp_f) / 1000.0 >= cfg["panic_c"]:
                    panic_until = now + cfg["panic_hold"]
            except (OSError, ValueError):
                pass
        if now < panic_until:
            pl2 = pl1
        pl2 = max(pl2, pl1)

        apply_limit(PL1_F, pl1)
        apply_limit(PL2_F, pl2)

        if last_logged is None or abs(pl1 - last_logged) >= 1.0:
            print("heat %.1f W; power %.1f W; PL1 %.1f W; PL2 %.1f W"
                  % (gov.heat, power, pl1, pl2), flush=True)
            last_logged = pl1


if __name__ == "__main__":
    main()

#!/usr/bin/env python3

import csv
import time
from collections import deque
from datetime import datetime
from pathlib import Path

OUT = Path("/var/log/surface-thermal")
INTERVAL = 1.0
PRE_EVENT = 240
POST_EVENT = 120
TRIGGER_KHZ = 250_000
TRIGGER_SAMPLES = 2

RAPL = Path("/sys/class/powercap/intel-rapl:0")
ZONE = Path("/sys/class/thermal/thermal_zone0/temp")
THROTTLE = Path("/sys/devices/system/cpu/cpu0/thermal_throttle")
POLICIES = sorted(
    Path("/sys/devices/system/cpu/cpufreq").glob("policy*")
)

FIELDS = [
    "timestamp",
    "seconds_from_event",
    "temperature_C",
    "package_power_W",
    "PL1_W",
    "PL2_W",
    "minimum_frequency_MHz",
    "policy_frequencies_MHz",
    "governor",
    "package_throttle_count",
    "package_throttle_delta",
    "core_throttle_count",
    "core_throttle_delta",
]


def read_int(path):
    try:
        return int(path.read_text().strip())
    except (OSError, ValueError):
        return None


def read_text(path):
    try:
        return path.read_text().strip()
    except OSError:
        return ""


def sample(previous):
    now = time.monotonic()
    timestamp = datetime.now().astimezone().isoformat(
        timespec="seconds"
    )

    frequencies = {}
    for policy in POLICIES:
        value = read_int(policy / "scaling_cur_freq")
        if value is not None:
            frequencies[policy.name] = value

    minimum_frequency = (
        min(frequencies.values()) if frequencies else None
    )

    temperature = read_int(ZONE)
    energy = read_int(RAPL / "energy_uj")
    energy_range = read_int(RAPL / "max_energy_range_uj")
    pl1 = read_int(RAPL / "constraint_0_power_limit_uw")
    pl2 = read_int(RAPL / "constraint_1_power_limit_uw")
    package_count = read_int(
        THROTTLE / "package_throttle_count"
    )
    core_count = read_int(
        THROTTLE / "core_throttle_count"
    )

    package_power = None
    package_delta = 0
    core_delta = 0

    if previous is not None:
        elapsed = now - previous["mono"]
        old_energy = previous["energy"]

        if energy is not None and old_energy is not None and elapsed > 0:
            delta = energy - old_energy
            if delta < 0 and energy_range is not None:
                delta += energy_range
            if delta >= 0:
                package_power = delta / elapsed / 1_000_000

        if package_count is not None and previous["package"] is not None:
            package_delta = max(
                0, package_count - previous["package"]
            )

        if core_count is not None and previous["core"] is not None:
            core_delta = max(0, core_count - previous["core"])

    row = {
        "timestamp": timestamp,
        "seconds_from_event": "",
        "temperature_C": (
            round(temperature / 1000, 1)
            if temperature is not None else ""
        ),
        "package_power_W": (
            round(package_power, 2)
            if package_power is not None else ""
        ),
        "PL1_W": round(pl1 / 1e6, 2) if pl1 is not None else "",
        "PL2_W": round(pl2 / 1e6, 2) if pl2 is not None else "",
        "minimum_frequency_MHz": (
            round(minimum_frequency / 1000, 1)
            if minimum_frequency is not None else ""
        ),
        "policy_frequencies_MHz": ";".join(
            f"{name}={value / 1000:.1f}"
            for name, value in frequencies.items()
        ),
        "governor": read_text(
            Path(
                "/sys/devices/system/cpu/cpufreq/policy0/"
                "scaling_governor"
            )
        ),
        "package_throttle_count": (
            package_count if package_count is not None else ""
        ),
        "package_throttle_delta": package_delta,
        "core_throttle_count": (
            core_count if core_count is not None else ""
        ),
        "core_throttle_delta": core_delta,
        "_mono": now,
    }

    state = {
        "mono": now,
        "energy": energy,
        "package": package_count,
        "core": core_count,
    }

    triggered = (
        minimum_frequency is not None
        and minimum_frequency <= TRIGGER_KHZ
    )

    return row, state, triggered


def save_event(rows, event_time, event_mono):
    OUT.mkdir(parents=True, exist_ok=True)
    filename = OUT / (
        f"thermal-event-{event_time.strftime('%Y%m%d-%H%M%S')}.csv"
    )

    for row in rows:
        row["seconds_from_event"] = round(
            row["_mono"] - event_mono, 1
        )

    with filename.open("w", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(
            {key: row.get(key, "") for key in FIELDS}
            for row in rows
        )

    print(f"Saved event: {filename}", flush=True)


def main():
    if not POLICIES:
        raise SystemExit("No CPU frequency policies found")

    if not ZONE.is_file() or not (RAPL / "energy_uj").is_file():
        raise SystemExit("Required thermal or RAPL sensor unavailable")

    OUT.mkdir(parents=True, exist_ok=True)

    history = deque(maxlen=PRE_EVENT)
    previous = None
    low_streak = 0

    event_rows = None
    event_time = None
    event_mono = None
    last_trigger = None

    print(
        f"Monitoring {len(POLICIES)} CPU policies; "
        f"trigger <= {TRIGGER_KHZ / 1000:.0f} MHz "
        f"for {TRIGGER_SAMPLES} consecutive samples",
        flush=True,
    )

    while True:
        cycle_start = time.monotonic()
        row, current, low_frequency = sample(previous)
        previous = current

        low_streak = low_streak + 1 if low_frequency else 0
        triggered = low_streak >= TRIGGER_SAMPLES
        now = current["mono"]

        if event_rows is None:
            if triggered:
                event_time = datetime.now().astimezone()
                event_mono = now
                event_rows = list(history)
                event_rows.append(row)
                last_trigger = now

                print(
                    f"Low-frequency event detected at {row['timestamp']}; "
                    f"minimum frequency "
                    f"{row['minimum_frequency_MHz']} MHz",
                    flush=True,
                )
            else:
                history.append(row)

        else:
            event_rows.append(row)

            if triggered:
                last_trigger = now

            if now - last_trigger >= POST_EVENT:
                save_event(event_rows, event_time, event_mono)

                event_rows = None
                event_time = None
                event_mono = None
                last_trigger = None
                low_streak = 0
                history.clear()
                history.append(row)

        time.sleep(
            max(0, INTERVAL - (time.monotonic() - cycle_start))
        )


if __name__ == "__main__":
    main()

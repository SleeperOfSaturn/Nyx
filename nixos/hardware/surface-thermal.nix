{ pkgs, ... }:

{
  services.power-profiles-daemon.enable = true;
  systemd.services.surface-thermal-clamp = {
    description = "Surface heat-soak power governor (RAPL PL1/PL2)";

    wantedBy = [ "multi-user.target" ];
    after = [
      "systemd-modules-load.service"
      "thermald.service"
      "power-profiles-daemon.service"
    ];

    environment = {
      PYTHONUNBUFFERED = "1";
      CLAMP_BUDGET_W = "16";      # sustained average the chassis can shed
      CLAMP_TAU_S = "60";         # heat-soak time constant
      CLAMP_KNEE_W = "3";         # taper begins at budget - knee
      CLAMP_PL1_FULL_W = "25.5";  # PL1 when cool (your old tier 0)
      CLAMP_PL2_W = "40";         # burst limit, kept high
    };

    serviceConfig = {
      Type = "simple";
      ExecStart =
        "${pkgs.python3}/bin/python3 ${../scripts/thermal-clamp.py}";

      Restart = "on-failure";
      RestartSec = 3;

      StateDirectory = "surface-thermal-clamp";
    };
  };

  systemd.services.surface-thermal-telemetry = {
    description = "Passive Surface thermal event recorder";

    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];

    serviceConfig = {
      Type = "simple";
      ExecStart =
        "${pkgs.python3}/bin/python3 ${../scripts/thermal-telemetry.py}";

      Restart = "on-failure";
      RestartSec = 5;

      LogsDirectory = "surface-thermal";
      LogsDirectoryMode = "0750";
      UMask = "0077";
    };
  };
}

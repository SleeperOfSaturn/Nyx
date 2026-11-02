# nixos/services/sunshine.nix
# Sunshine game streaming host for Moonlight
# Host: Surface Laptop 4 / Intel Iris Xe / Pantheon

{ config, pkgs, lib, ... }:

let
  steam = "/run/current-system/sw/bin/steam";

  stateDir = "/home/saturn/.config/sunshine";
in
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    openFirewall = true;
    capSysAdmin = true;

    settings = {
      sunshine_name = "nixos";

      # --- Display ------------------------------------------------
      # Native Surface Laptop 4 display: 2496x1664 @ 60Hz
      fps = "[30, 60]";

      resolutions = "[2496x1664, 1920x1280, 1920x1080, 1872x1248, 1600x900, 1280x720, 1248x832]";

      # --- Capture ------------------------------------------------
      capture = "kms";

      # --- Encoding -----------------------------------------------
      encoder = "vaapi";
      adapter_name = "/dev/dri/renderD128";

      # Intel Tiger Lake Quick Sync:
      # HEVC supported; AV1 hardware encoding unavailable.
      hevc_mode = 1;
      av1_mode = 0;

      # --- Input --------------------------------------------------
      gamepad = "auto";

      # --- State --------------------------------------------------
      credentials_file = "${stateDir}/sunshine_state.json";
      file_state = "${stateDir}/sunshine_state.json";
      log_path = "${stateDir}/sunshine.log";
    };

    applications.apps = [
      {
        name = "Steam Big Picture";
        detached = [
          "${steam} steam://open/bigpicture"
        ];

        prep-cmd = [
          {
            do = "";
            undo = "${steam} steam://close/bigpicture";
          }
        ];
      }
    ];
  };

  # Virtual keyboard, mouse and gamepad support
  hardware.uinput.enable = true;

  users.users.saturn.extraGroups = [
    "uinput"
    "video"
    "render"
  ];

  # Ensure Sunshine's state directory exists
  systemd.tmpfiles.rules = [
    "d ${stateDir} 0700 saturn users -"
  ];
}


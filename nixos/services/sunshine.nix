# Sunshine game streaming host for Moonlight
# Host: Surface Laptop 4 / Intel Iris Xe / Pantheon, streaming the physical panel

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

      # --- Capture ---
      # KMS reads the physical panel directly. Works with the lid open.
      capture = "kms";

      # --- Encoding ---
      encoder = "vaapi";
      adapter_name = "/dev/dri/renderD128";

      # Intel Tiger Lake Quick Sync
      hevc_mode = 1;
      av1_mode = 0;

      # --- Input ---
      gamepad = "auto";

      # --- State ---
      credentials_file = "${stateDir}/sunshine_state.json";
      file_state = "${stateDir}/sunshine_state.json";
      log_path = "${stateDir}/sunshine.log";
    };

    applications.apps = [
      {
        name = "Steam Big Picture";
        detached = [ "${steam} steam://open/bigpicture" ];
      }

      {
        name = "Desktop";
      }
    ];
  };

  hardware.uinput.enable = true;

  users.users.saturn.extraGroups = [
    "uinput"
    "video"
    "render"
  ];

  systemd.tmpfiles.rules = [
    "d ${stateDir} 0700 saturn users -"
  ];
}

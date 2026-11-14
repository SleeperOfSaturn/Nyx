# nixos/services/usbmuxd.nix

{ config, pkgs, ... }:

{
  services.usbmuxd.enable = true;

  users.users.saturn.extraGroups = [
    "usbmux"
  ];
}

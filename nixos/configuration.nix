#nixos/configuration.nix

{ config, pkgs, lib, ... }:

{
  imports = [
    ./system/bluetooth.nix
    ./system/boot.nix
    ./system/disk.nix
    ./system/flake-packages.nix
    ./system/fonts.nix
    ./system/hardware-configuration.nix
    
    ./system/locales.nix
    ./system/networking.nix
    ./system/nix-settings.nix
    ./system/wine.nix

    ./services/audio.nix
    ./services/avahi.nix
    ./services/display.nix
    ./services/flatpak.nix
    ./services/libvirt.nix
    ./services/misc.nix
    ./services/steam.nix
    ./services/sunshine.nix

    ./surface/surface-thermal.nix

    ./users/fish.nix
    ./users/saturn.nix
  ];

  environment.systemPackages = import ../packages/packages.nix pkgs;
  system.stateVersion = "26.05";
}

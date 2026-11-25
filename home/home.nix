{ config, pkgs, ... }:

{
  home.stateVersion = "26.05";

  imports = [
    ./nixcord.nix
    ./firefox.nix
    ./lazyvim.nix
    ./elementary.nix
  ];

}

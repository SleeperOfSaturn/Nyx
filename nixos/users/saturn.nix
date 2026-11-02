#nixos/users/saturn.nix
{ pkgs, ... }:

{
  users.users.saturn = {
    isNormalUser = true;
    description = "saturn";
    shell = pkgs.fish;

    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "dialout"
      "audio"
      "input"
      "surface-control"
    ];
  };
}

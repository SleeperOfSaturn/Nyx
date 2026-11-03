#nixos/system/nix-settings.nix
{ ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "saturn" ];
  };
  nixpkgs.config = {
    allowUnfree = true;
  };
  programs.nix-ld.enable  = true;
  services.usbmuxd.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 15d --keep 3";
    flake = "/home/saturn/Nyx";
  };
}

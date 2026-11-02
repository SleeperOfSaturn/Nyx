# nixos/system/networking.nix

{ ... }:

{
  networking.hostName = "nixos";

  # NetworkManager handles Ethernet, Wi-Fi and DHCP
  networking.networkmanager.enable = true;
  networking.useDHCP = false;

  # Stop Wi-Fi power saving from causing drops
  networking.networkmanager.wifi.powersave = false;

  # Cloudflare DNS
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  # BBR congestion control with fq queuing
  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";
  };
}

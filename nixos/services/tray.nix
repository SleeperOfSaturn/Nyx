# nixos/services/indicator-application.nix

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    indicator-application-gtk3
  ];

  systemd.user.services.indicator-application = {
    description = "Ayatana Indicator Application Service";

    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.indicator-application-gtk3}/libexec/indicator-application/indicator-application-service";
      Restart = "on-failure";
    };
  };
}


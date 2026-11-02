{ ... }:

{
  services.avahi = {
    enable = true;
    nssmdns4 = true;      # resolve *.local hostnames
    openFirewall = true;  # allow mDNS traffic (UDP 5353)

    settings.publish = {
      disable-publishing = false;
      publish-addresses = true;
      disable-user-service-publishing = false;
    };
  };
}

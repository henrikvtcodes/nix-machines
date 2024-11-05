{...}: {
  # Firewall config
  networking.firewall = {
    allowedTCPPorts = [
      80
      443
      69
      5201
    ];
    allowedUDPPorts = [53];
    enable = true;
  };

  # Static interfaces configuration
  networking = {
    networkmanager.enable = false;
    dhcpcd.enable = false;
    interfaces.ens3 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "162.120.71.172";
          prefixLength = 24;
        }
      ];
      ipv6.addresses = [
        {
          address = "2a0a:8dc0:2000:a5::2";
          prefixLength = 126;
        }
      ];
    };
    defaultGateway = {
      address = "162.120.71.1";
      interface = "ens3";
    };
    defaultGateway6 = {
      address = "2a0a:8dc0:2000:a5::1";
      interface = "ens3";
    };
  };
}

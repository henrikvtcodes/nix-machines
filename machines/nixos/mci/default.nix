{...}: {
  imports = [
    ./hardware-config.nix
    ./routing.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  virtualisation.podman.enable = false;

  home.henrikvt.enable = true;
  users.henrikvt.enablePasswordFile = false;

  my.services.tailscale.enable = true;

  services.openssh = {
    openFirewall = false;
    ports = [22 69];
  };

  networking = {
    useDHCP = false;
    dhcpcd.enable = false;
    hostName = "mci";
    firewall = {
      allowedTCPPorts = [
        69
      ];
      allowedUDPPorts = [53];
      enable = true;
    };
    interfaces = {
        lo.ipv6.addresses = [
          {
            address = "2602:f542:bee::1";
            prefixLength = 48;
          }
          {
            address = "155.103.251.1";
            prefixLength = 24;
          }
        ];
      ens18 = {
        ipv4.addresses = [
          {
            address = "23.143.82.39";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = "2602:fc26:12:1::39";
            prefixLength = 48;
          }
          {
            address = "2602:fc26:12:1::beef";
            prefixLength = 48;
          }
        ];
      };
    };

    defaultGateway = {
      address = "23.143.82.1";
      interface = "ens18";
    };
    defaultGateway6 = {
      address = "2602:fc26:12::1";
      interface = "ens18";
    };
  };
}

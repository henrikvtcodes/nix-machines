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
      enable = true;
      allowedTCPPorts = [69];
      allowedUDPPorts = [53];
      extraInputRules = ''
        ip saddr 23.143.82.0/24 tcp dport 179 accept
        ip6 saddr 2602:fc26:12::/48 tcp dport 179 accept
        tcp dport 179 drop
      '';
    };
    interfaces = {
      lo = {
        ipv4.addresses = [
          {
            address = "155.103.251.1";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = "2602:f542:bee::1";
            prefixLength = 48;
          }
        ];
      };
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

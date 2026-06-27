{...}: {
  imports = [
    ./hardware-config.nix
    ./dns
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  virtualisation.podman.enable = true;

  home.henrikvt.enable = true;
  users.henrikvt.enablePasswordFile = false;

  my.services = {
    tailscale = {
      enable = true;
      advertiseExitNode = true;
    };
    caddy.enable = true;

    routing = {
      enable = true;
      asn = 63477;

      ipv4 = {
        source = "155.103.251.1";
        machine = "23.143.82.39";
        localPrefixes = ["155.103.251.0/24"];
        staticRoutes = [
          {
            prefix = "155.103.251.0/24";
            via = "SOURCE4";
          }
        ];
      };

      ipv6 = {
        source = "2602:f542:bee::1";
        machine = "2602:fc26:12:1::39";
        localPrefixes = ["2602:f542:bee::/48"];
        staticRoutes = [
          {
            prefix = "2602:f542:bee::/48";
            via = "SOURCE6";
          }
        ];
      };

      rpki.enable = true; # default; set false to disable RTR

      irr = {
        enable = true;
        host = "rr.ntt.net"; # default
        refreshInterval = "hourly";
      };

      excludeTailscale = true;

      peers = [
        # Transit — no IRR filtering, accepts default route
        {
          name = "up_as1003";
          role = "transit";
          asn = 1003;
          neighborV4 = ["23.143.82.1"];
          neighborV6 = ["2602:fc26:12::1"];
          asSet = "AS-ANDREWNET";
        }

        # Regular peer — IRR filtered
        {
          name = "pe_as215207";
          role = "peer";
          asn = 215207;
          neighborV4 = ["23.143.82.38"];
          neighborV6 = ["2602:fc26:12:1::38"];
          asSet = "AS-AETHERNET-ALL";
        }
      ];
    };
  };

  services.caddy.virtualHosts = {
    "mci.unicycl.ing" = {
      extraConfig = ''
        respond "What're you doing here?"
      '';
    };
  };

  services.openssh = {
    openFirewall = false;
    ports = [22 69];
  };

  users.users.henrikvt.extraGroups = ["bird" "knot" "pcap"];

  programs.tcpdump.enable = true;

  networking = {
    useDHCP = false;
    dhcpcd.enable = false;
    hostName = "mci";
    firewall = {
      enable = true;
      allowedTCPPorts = [69 80 443 2023 8080];
      allowedUDPPorts = [80 443];
      extraInputRules = ''
        ip saddr 23.143.82.0/24 tcp dport 179 accept
        ip6 saddr 2602:fc26:12::/48 tcp dport 179 accept
        tcp dport 179 drop
        ip daddr 155.103.251.53 udp dport 53 accept
        ip daddr 155.103.251.53 tcp dport 53 accept
        ip6 daddr 2602:f542:bee::53 udp dport 53 accept
        ip6 daddr 2602:f542:bee::53 tcp dport 53 accept
        udp dport 53 drop
        tcp dport 53 drop
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
          {
            address = "2602:f542:bee::53";
            prefixLength = 48;
          }
        ];
      };
      ens18 = {
        ipv4.addresses = [
          {
            address = "23.143.82.39";
            prefixLength = 25;
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

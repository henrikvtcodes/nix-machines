{ ...}: {
  imports = [
    ./hardware-config.nix
    ./routing.nix
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

  # virtualisation.podman.settings = {
  #   networks = {
  #     ripe-atlas = {
  #       driver = "macvlan";
  #       interfaces = {
  #         ens18 = {};
  #       };
  #       ipam = {
  #         type = "host-local";
  #         ranges = [
  #           [
  #             {
  #               subnet = "155.103.251.0/24";
  #               gateway = "155.103.251.1";
  #             }
  #           ]
  #           [
  #             {
  #               subnet = "2602:f542:bee::/48";
  #               gateway = "2602:f542:bee::1";
  #             }
  #           ]
  #         ];
  #       };
  #     };
  #   };
  # };

  # virtualisation.oci-containers.containers = [
  #   {
  #     image = "jamesits/ripe-atlas:latest-probe";
  #     extraOptions = [
  #       "--network=ripe-atlas"
  #       "--ip=155.103.251.2"
  #       "--ipv6=2602:f542:bee::2"
  #       "--cap-add=NET_RAW"
  #       "--cap-add=SETUID"
  #       "--cap-add=SETGID"
  #       "--cap-add=CHOWN"
  #       "--cap-add=DAC_OVERRIDE"
  #     ];
  #   }
  # ];

  # Disable rp_filter to allow asymmetric routing for container traffic
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.rp_filter" = 0;
    "net.ipv4.conf.default.rp_filter" = 0;
  };

  users.users.henrikvt.extraGroups = ["bird" "knot"];

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

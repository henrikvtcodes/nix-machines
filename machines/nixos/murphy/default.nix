{
  lib,
  config,
  ...
}: {
  imports = [
    ./hwconfig.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  virtualisation.podman.enable = true;

  home.henrikvt.enable = true;
  users.henrikvt.enablePasswordFile = false;

  #   my.services = {
  #     tailscale = {
  #       enable = true;
  #       advertiseExitNode = true;
  #       advertiseRoutes = {
  #         enable = true;
  #         routes = [
  #           "10.200.20.0/24"
  #           "10.200.30.0/24"
  #         ];
  #       };
  #     };
  #     caddy.enable = false;
  #
  #     routing = {
  #       enable = true;
  #       asn = 63477;
  #
  #       ipv4 = {
  #         source = "10.0.0.1";
  #         machine = "10.0.0.1";
  #       };
  #
  #       ipv6 = {
  #         source = "2602:f542:530::1";
  #         machine = "2602:f542:530::1";
  #         localPrefixes = ["2602:f542:530::/48"];
  #         staticRoutes = [
  #           {
  #             prefix = "2602:f542:bee::/48";
  #             via = "SOURCE6";
  #           }
  #         ];
  #       };
  #
  #       rpki.enable = true; # default; set false to disable RTR
  #
  #       irr = {
  #         enable = true;
  #         host = "rr.ntt.net"; # default
  #         refreshInterval = "daily";
  #       };
  #
  #       excludeTailscale = true;
  #
  #       peers = [
  #         {
  #           name = "pe_vermontix";
  #           role = "ixp-rs";
  #           asn = 62848;
  #           neighborV6 = ["2001:504:137::feed:1" "2001:504:137::feed:2"];
  #           asSet = "AS-VERMONTIX";
  #           maxPrefixV6 = 500;
  #         }
  #       ];
  #     };
  #   };

  services = {
    qemuGuest.enable = true;
  };

  users.users.henrikvt.extraGroups = ["bird" "knot" "pcap"];

  programs.tcpdump.enable = true;

  age.secrets = {
  };

  systemd.network = {
    links = {
      "10-wan" = {
        matchConfig = {
          MACAddress = "bc:24:11:1a:ef:32";
          Type = "ether";
        };
        linkConfig.Name = "wan0";
      };
      "20-ix" = {
        matchConfig = {
          MACAddress = "bc:24:11:88:8f:fa";
          Type = "ether";
        };
        linkConfig.Name = "ix0";
      };
    };
    networks = {
      # "0-loopback" = {
      #   matchConfig.Name = "lo";
      #   addresses = [
      #     {
      #       Address = "2602:f542:530::1/48";
      #     }
      #   ];
      # };
      "10-mgmt" = {
        matchConfig.Name = "wan0";
        networkConfig = {
          Description = "Backend Management NIC";
          DHCP = "no";
        };
        gateway = ["134.195.76.68" "2602:FD9A:1000:202::1"];
        address = ["134.195.76.69/31" "2602:FD9A:1000:202::/64"];
      };
      # "20-ix" = {
      #   matchConfig.Name = "ix0";
      #   networkConfig = {
      #     Description = "MASS-IX Peering LAN";
      #     DHCP = "no";
      #     IPv6AcceptRA = "no";
      #     IPv6SendRA = "no";
      #     EmitLLDP = "no";
      #   };
      #   addresses = [
      #     {
      #       Address = "2001:504:137::63:477/64";
      #     }
      #   ];
      # };
    };
  };
  networking = {
    hostName = "reverence";
    firewall = {
      enable = true;
      allowedTCPPorts = [22 69];
    };
    useNetworkd = true;
  };

  systemd.network.enable = true;

  system.stateVersion = "25.11";
}

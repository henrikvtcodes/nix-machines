{lib, ...}: {
  imports = [
    ./hardware-config.nix
    # ./routing
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
      advertiseExitNode = false;
    };
    caddy.enable = false;

        routing = {
      enable = true;
      asn = 63477;

     ipv4 = {
        source = "149.112.191.230";
        machine = "149.112.191.230";
      };

      ipv6 = {
        source = "2602:f542:1fd::1";
        machine = "2602:fc26:12:1::39";
        localPrefixes = ["2602:f542:1fd::/48"];
        staticRoutes = [
          {
            prefix = "2602:f542:1fd::/48";
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
        {
          name = "up_as21647";
          role = "transit";
          asn = 21647;
          neighborV4 = ["149.112.191.193"];
          neighborV6 = ["fe80::6e63:f8ff:fea2:d599"];
          asSet = "AS-LIGHTBOARD";
        }

        {
          name = "pe_aix_spfdma";
          role = "ixp-rs";
          asn = 11150;
          neighborV6 = ["149.112.82.6" "149.112.82.7"  "2001:504:136::6 " " 2001:504:136::7"];
          asSet = "AS-SPFDMA-AIX";
          maxPrefixV4 = 500;
          maxPrefixV6 = 500;
        }
      ];
    };
  };

  services = {
    qemuGuest.enable = true;
  };

  users.users.henrikvt.extraGroups = ["bird" "knot" "pcap"];

  programs.tcpdump.enable = true;

  systemd.network = {
    links = {
      "10-wan0" = {
        matchConfig = {
          MACAddress = "BC:24:11:F3:91:9A";
          Type = "ether";
        };
        linkConfig.Name = "wan0";
      };
      "10-ix0" = {
        matchConfig = {
          MACAddress = "bc:24:11:a3:8d:cf";
          Type = "ether";
        };
        linkConfig.Name = "ix0";
      };
    };
    networks = {
      "0-loopback" = {
        matchConfig.Name = "lo";
        addresses = [
          {
            Address = "2602:f542:1fd::1/48";
          }
        ];
      };
      "10-wan0" = {
        matchConfig.Name = "wan0";
        networkConfig = {
          Description = "Backend Management NIC";
          DHCP = "yes";
        };
      };
      "20-ix0" = {
        matchConfig.Name = "ix0";
        networkConfig = {
          Description = "AIX SPFDMA Peering LAN";
          DHCP = "no";
          IPv6AcceptRA = "no";
          IPv6SendRA = "no";
          EmitLLDP = "no";
        };
        addresses = [
          {
            Address = "149.112.82.9/24";
          }
          {
            Address = "2001:504:136::9/64";
          }
        ];
      };
    };
  };

  networking = {
    hostName = "homer";
    firewall = {
      enable = true;
      allowedTCPPorts = [22 69 80 179 443 2023 8080];
      allowedUDPPorts = [80 443];
    };
    useNetworkd = true;
  };

  systemd.network.enable = true;

  system.stateVersion = "26.05";
}

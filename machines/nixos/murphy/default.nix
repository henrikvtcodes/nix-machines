{
  lib,
  config,
  ...
}: {
  imports = [
    ./hwconfig.nix
    ./containers.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  virtualisation.podman.enable = true;

  home.henrikvt.enable = true;
  users.henrikvt.enablePasswordFile = false;

  my.services.tailscale.enable = false;

    my.services = {
      # tailscale = {
      #   enable = true;
      #   advertiseExitNode = true;
      #   advertiseRoutes = {
      #     enable = true;
      #     routes = [
      #       "10.200.20.0/24"
      #       "10.200.30.0/24"
      #     ];
      #   };
      # };
      caddy.enable = false;

      routing = {
        enable = true;
        asn = 63477;

        ipv4 = {
          source = "134.195.76.69";
          machine = "134.195.76.69";
        };

        ipv6 = {
          source = "2602:f542:70::1";
          machine = "2602:f542:70::1";
          localPrefixes = ["2602:f542:70::/48"];
          staticRoutes = [
            {
              prefix = "2602:f542:70::/48";
              via = "SOURCE6";
            }
          ];
        };
        irr = {
          enable = true;
          refreshInterval = "hourly";
        };
        peers = [
          {
            name = "rs_massix";
            role = "ixp-rs";
            asn = 26563;
            irrFilter = false;
            neighborV4 = ["206.53.143.252" "206.53.143.253"];
            neighborV6 = ["2001:504:47::ce35:8ffc:1" "2001:504:47::ce35:8ffd:1"];
          }
          {
            name = "pe_cloudflare";
            role = "peer";
            asn = 13335;
            asSet = "AS-CLOUDFLARE";
            neighborV4 = ["206.53.143.9"];
            neighborV6 = ["2001:504:47::3417:0:1"];
          }
        ];
      };
    };

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
      "0-lo" = {
        matchConfig.Name = "lo";
        address = ["2602:f542:70::1/128"];
      };
      "10-wan" = {
        matchConfig.Name = "wan0";
        networkConfig = {
          Description = "Backend Management NIC";
          DHCP = "no";
        };
        gateway = ["134.195.76.68" "2602:FD9A:1000:202::1"];
        address = ["134.195.76.69/31" "2602:FD9A:1000:202::2/128"];
        # Keep OOB-sourced traffic on wan0 regardless of BGP routes
        # installed in the main table (which would send replies out ix0).
        routingPolicyRules = [
          {
            From = "134.195.76.69/32";
            Table = 100;
            Priority = 100;
          }
          {
            From = "2602:FD9A:1000:202::2/128";
            Table = 100;
            Priority = 100;
          }
        ];
        routes = [
          {
            Gateway = "134.195.76.68";
            Table = 100;
          }
          {
            Gateway = "2602:FD9A:1000:202::1";
            GatewayOnLink = true; # our address is a /128, so the gateway isn't in a connected prefix
            Table = 100;
          }
        ];
      };
      "20-ix" = {
        matchConfig.Name = "ix0";
        networkConfig = {
          Description = "MASS-IX Peering LAN";
          DHCP = "no";
          IPv6AcceptRA = "no";
          IPv6SendRA = "no";
          EmitLLDP = "no";
        };
        addresses = [
          {
            Address = "206.53.143.97/24";
          }
          {
            Address = "2001:504:47::F7F5:0:1/64";
          }
        ];
      };
    };
  };
  networking = {
    hostName = "murphy";
    firewall = {
      enable = true;
      allowedTCPPorts = [22 69];
    };
    useNetworkd = true;
  };

  systemd.network.enable = true;

  system.stateVersion = "25.11";
}

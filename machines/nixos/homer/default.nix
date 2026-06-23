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
  };

  services = {
    qemuGuest.enable = true;
  };

  users.users.henrikvt.extraGroups = ["bird" "knot" "pcap"];

  programs.tcpdump.enable = true;

  systemd.network = {
    links = {
      "10-mgmt" = {
        matchConfig = {
          MACAddress = "BC:24:11:F3:91:9A";
          Type = "ether";
        };
        linkConfig.Name = "nic0";
      };
      # "20-ix" = {
      #   matchConfig = {
      #     MACAddress = "38:2C:DB:06:34:47";
      #     Type = "ether";
      #   };
      #   linkConfig.Name = "nic1";
      # };
    };
    networks = {
      "0-loopback" = {
        matchConfig.Name = "lo";
        addresses = [
          {
            Address = "2602:f542:530::1/48";
          }
        ];
      };
      "10-mgmt" = {
        matchConfig.Name = "nic0";
        networkConfig = {
          Description = "Backend Management NIC";
          DHCP = "yes";
        };
      };
      # "20-ix" = {
      #   matchConfig.Name = "nic1";
      #   networkConfig = {
      #     Description = "Vermont IX Peering LAN";
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
    hostName = "homer";
    firewall = {
      enable = true;
      allowedTCPPorts = [22 69 80 443 2023 8080];
      allowedUDPPorts = [80 443];
    };
    useNetworkd = true;
  };

  systemd.network.enable = true;

  system.stateVersion = "26.05";
}

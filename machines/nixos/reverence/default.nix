{...}: {
  imports = [
    ./hardware-config.nix
    ./routing
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
    openssh = {
      openFirewall = false;
      ports = [22 69];
    };
  };

  users.users.henrikvt.extraGroups = ["bird" "knot" "pcap"];

  programs.tcpdump.enable = true;

  systemd.network = {
    links = {
      "10-mgmt" = {
        matchConfig = {
          MACAddress = "BC:24:11:21:8A:57";
          Type = "ether";
        };
        linkConfig.Name = "nic0";
      };
      "20-ix" = {
        matchConfig = {
          MACAddress = "38:2C:DB:06:34:47";
          Type = "ether";
        };
        linkConfig.Name = "nic1";
      };
    };
    networks = {
      "10-mgmt" = {
        matchConfig.Name = "nic0";
        networkConfig = {
          Description = "Backend Management NIC";
          DHCP = "yes";
        };
      };
      "20-ix" = {
        matchConfig.Name = "nic1";
        networkConfig = {
          Description = "Vermont IX Peering LAN";
          DHCP = "no";
          IPv6AcceptRA = "no";
          IPv6SendRA = "no";
          EmitLLDP = "no";
        };
        addresses = [
          {
            Address = "2001:504:136::63:477/64";
          }
        ];
      };
    };
  };

  networking = {
    hostName = "reverence";
    firewall = {
      enable = true;
      allowedTCPPorts = [22 69 80 443 2023 8080];
      allowedUDPPorts = [80 443];
    };
    nameservers = [];
  };

  system.stateVersion = "25.11";
}

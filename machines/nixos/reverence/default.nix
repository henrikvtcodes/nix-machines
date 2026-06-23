{
  lib,
  config,
  ...
}: {
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
  };

  users.users.henrikvt.extraGroups = ["bird" "knot" "pcap"];

  programs.tcpdump.enable = true;

  age.secrets = {
    reverenceWgPrivkey = {
      file = ../../../secrets/reverenceWgPrivkey.age;
      owner = "systemd-network";
    };
    # aristaEapiConf = {
    #   file = ../../../secrets/aristaEapiConf.age;
    #   owner = "eoxporter";
    #   group = "eoxporter";
    # };
    # unpollerPassword = {
    #   owner = "unifi-poller";
    #   file = ../../../secrets/valcourUnpollerPassword.age;
    # };
  };

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
    netdevs = {
      "10-violet-wireguard" = {
        enable = true;
        netdevConfig = {
          Kind = "wireguard";
          Name = "violet0";
        };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets.reverenceWgPrivkey.path;
          RouteMetric = 2048;
        };
        wireguardPeers = [
          {
            AllowedIPs = [
              "10.200.0.0/16"
              "172.16.255.0/30"
            ];
            Endpoint = "162.120.71.136:51820";
            PersistentKeepalive = 15;
            PublicKey = "uQKOe+7uF8Jm+98Uc64sEWJpuLpGH/BykXYySHkW6jg=";
          }
        ];
      };
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
      "10-violet-wg" = {
        matchConfig = {Name = "violet0";};
        networkConfig.DHCP = "no";
        addresses = [
          {
            Address = "172.16.255.2/30";
          }
        ];
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
            Address = "2001:504:137::63:477/64";
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
    nameservers = lib.mkForce ["132.198.201.10" "132.198.202.10" "2620:104:e001:1002::a" "2620:104:e001:1003::a"];
    useNetworkd = true;
  };

  systemd.network.enable = true;

  system.stateVersion = "25.11";
}

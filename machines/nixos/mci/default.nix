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

  environment.etc = {
    "knot/zones/251.103.155.in-addr.arpa.zone".source = ./dns/251.103.155.in-addr.arpa.zone;
    "knot/zones/0.2.4.5.f.2.0.6.2.ip6.arpa.zone".source = ./dns/0.2.4.5.f.2.0.6.2.ip6.arpa.zone;
  };

  services = {
    openssh = {
      openFirewall = false;
      ports = [22 69];
    };
    knot = {
      enable = true;
      settings = {
        server = {
          listen = ["155.103.251.53@53" "2602:f542:bee::53@53"];
        };
        mod-synthrecord = [
          {
            id = "pine-1-rdns";
            type = "reverse";
            origin = "rdns4.static.as63477.net";
            network = "155.103.251.0/24";
            ttl = 600;
          }
          {
            id = "spruce-1-rdns";
            type = "reverse";
            origin = "rdns6.static.as63477.net";
            network = "2602:F542::/36";
            ttl = 600;
          }
        ];
        zone = [
          {
            domain = "251.103.155.in-addr.arpa";
            file = "251.103.155.in-addr.arpa.zone";
            module = "mod-synthrecord/pine-1-rdns";
            storage = "/etc/knot/zones";
          }
          {
            domain = "0.2.4.5.f.2.0.6.2.ip6.arpa";
            file = "0.2.4.5.f.2.0.6.2.ip6.arpa.zone";
            module = "mod-synthrecord/spruce-1-rdns";
            storage = "/etc/knot/zones";
          }
        ];
      };
    };
  };

  networking = {
    useDHCP = false;
    dhcpcd.enable = false;
    hostName = "mci";
    firewall = {
      enable = true;
      allowedTCPPorts = [69 80 443];
      allowedUDPPorts = [53 80 443];
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

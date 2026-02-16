{pkgs, ...}: {
  imports = [
    ./hardware-config.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  virtualisation.podman.enable = false;

  home.henrikvt.enable = true;
  users.henrikvt.enablePasswordFile = false;

  my.services.tailscale.enable = true;

  networking = {
    useDHCP = false;
    dhcpcd.enable = false;
    hostName = "mci";
    interfaces = {
      #   lo.ipv6.addresses = [
      #     {
      #       address = "2602:fbcf:df::1";
      #       prefixLength = 48;
      #     }
      #     {
      #       address = "2602:fbcf:d3::1";
      #       prefixLength = 48;
      #     }
      #   ];
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
          {
            address = "2602:fc26:12:1::beef";
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

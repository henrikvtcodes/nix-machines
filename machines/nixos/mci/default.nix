{...}: {
  imports = [
    ../../modules/common.nix

    ./hardware-configuration.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  services.qemuGuest.enable = true;

  networking = {
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

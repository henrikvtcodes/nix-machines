{pkgs, ...}: {
  imports = [
    ./hardware-config.nix
  ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.loader.efi.canTouchEfiVariables = false;

  home.henrikvt.enable = false;
  users.henrikvt.enablePasswordFile = false;
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [inetutils q btop git vim];

  networking = {
    firewall.enable = false;
    wireless.enable = false;
    networkmanager.enable = false;
    nameservers = [
      "9.9.9.9"
      "149.112.112.9"
      "2620:fe::9"
      "2620:fe::fe"
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
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

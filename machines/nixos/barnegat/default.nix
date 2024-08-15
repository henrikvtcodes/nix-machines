{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-config.nix
    # ./disk-config.nix
  ];

  networking.hostName = "barnegat";
  # networking.hostId = "bcf61aa3";
  services.qemuGuest.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device = "/dev/vda";

  networking = {
    firewall.enable = false;
    networkmanager.enable = false;
    useDHCP = false;
    interfaces.ens3 = {
      ipv4.addresses = [
        {
          address = "162.120.71.172";
          prefixLength = 24;
        }

      ];
      ipv6.addresses = [
        {
          address = "2a0a:8dc0:2000:a5::2";
          prefixLength = 126;
        }
      ];
    };
    defaultGateway = {
      address = "162.120.71.1";
      interface = "ens3";
    };
    defaultGateway6 = {
      address = "2a0a:8dc0:2000:a5::1";
      interface = "ens3";
    };
    nameservers = [
      "9.9.9.10"
      "149.112.112.10"
      "2620:fe::10"
      "2620:fe::fe:10"
    ];
  };

  services.prometheus.exporters.node.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05";
}

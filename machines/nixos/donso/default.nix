{pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-config.nix
    ./disk-config.nix
    ./services
  ];

  networking.hostName = "donso";
  networking.hostId = "bcf61aa3";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.forceImportRoot = false;

  bootDiskGB = {
    enable = true;
    diskPath = "/dev/disk/by-id/ata-SAMSUNG_MZ7TY128HDHP-000H1_S2ZYNB0J110815";
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      5201
    ];
  };

  services.prometheus.exporters.node = {
    enable = true;
  };

  # ZFS Stuff
  environment.systemPackages = with pkgs; [
    zfs
  ];

  my.services.tailscale = {
    advertiseExitNode = true;
    advertiseRoutes = {
      enable = true;
      routes = [
        "132.198.0.0/16"
        "2620:104:e000::/40"

        # "132.198.59.133/32" # EMSWEB
      ];
    };
  };

  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
    };
    trim = {
      enable = true;
      interval = "monthly";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05";
}

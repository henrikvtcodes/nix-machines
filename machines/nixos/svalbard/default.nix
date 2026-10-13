{
  pkgs,
  inputs,
  system,
  config,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-config.nix
    inputs.copyparty.nixosModules.default
  ];

  boot.loader = {
    efi.canTouchEfiVariables = false;
    grub = {
      enable = true;
      copyKernels = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      zfsSupport = true;
      mirroredBoots = [
        {
          devices = ["nodev"];
          path = "/boot";
        }
      ];
    };
  };

  networking = {
    hostName = "svalbard";
    hostId = "8425e349"; # for ZFS
    firewall.enable = false;
    wireless.enable = false;
    networkmanager.enable = false;
  };

  # ZFS Settings
  environment.systemPackages = with pkgs; [zfs];

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

  services.copyparty = {
    enable = true;
    package = inputs.copyparty.packages.${system}.copyparty.override {
      withSFTP = true;
      withSMB = true;
    };
    settings = {
      i = "0.0.0.0";
      p = [19190];
      # what ip to use when id'ing clients
      # rproxy = -2;
      http-only = true;

      # mDNS advertisement (also advertises webdav/ftp/smb)
      zm = true;

      # FTP server + passive port range
      ftp = 3921;
      "ftp-pr" = "12000-12099";

      # SFTP server with password auth (hostkeys are generated under /var/lib/copyparty)
      sftp = 3922;
      "sftp-pw" = true;

      # SMB server, read-write; port 445 is granted via CAP_NET_BIND_SERVICE below
      smbw = true;
      "smb-port" = 445;

      # allow users to change their own passwords from the control-panel
      chpw = true;
      "chpw-db" = "/var/lib/copyparty/copyparty/chpw.json";
    };

    accounts.henrikvt.passwordFile = config.age.secrets.copypartyPassword.path;

    volumes = {
      # create a volume at "/" (the webroot), which will
      "/media" = {
        # share the contents of "/srv/copyparty"
        path = "/mnt/storage/media";
        # see `copyparty --help-accounts` for available options
        access = {
          # everyone gets read-access
          r = "*";
          # henrikvt can read/write/move/delete
          rwmd = "henrikvt";
        };
        # # see `copyparty --help-flags` for available options
        flags = {
          # # "fk" enables filekeys (necessary for upget permission) (4 chars long)
          # fk = 4;
          # scan for new files every 60sec
          scan = 60;
          # volflag "e2d" enables the uploads database
          e2d = true;
          # "d2t" disables multimedia parsers (in case the uploads are malicious)
          # d2t = true;
          # skips hashing file contents if path matches *.iso
          nohash = "\.iso$";
        };
      };

      "/backupshare" = {
        path = "/mnt/storage/backups/share";
        access = {
          # henrikvt can read/write/move/delete their own backups
          rwmd = "henrikvt";
        };
        flags = {
          scan = 60;
          e2d = true;
          d2t = true;
          nohash = "\.iso$";
        };
      };
    };
  };

  # copyparty runs unprivileged, so grant it the ability to bind SMB port 445
  systemd.services.copyparty.serviceConfig = {
    AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];
    CapabilityBoundingSet = ["CAP_NET_BIND_SERVICE"];
  };

  # initial/reset password for the henrikvt account; self-service changes are
  # stored in the chpw database (/var/lib/copyparty/copyparty/chpw.json)
  age.secrets.copypartyPassword = {
    file = ../../../secrets/henrikUserPassword.age;
    owner = "copyparty";
    group = "copyparty";
  };

  my.services.tailscale = {
    advertiseExitNode = true;
  };

  services.logrotate.checkConfig = false;

  boot.supportedFilesystems = ["zfs"];
  boot.zfs.forceImportRoot = false;

  # Healthcheck Ping
  # age.secrets.svalbardHealthcheckUrl.file = ../../../secrets/svalbardHealthcheckUrl.age;
  # my.services.betteruptime = {
  #   enable = true;
  #   healthcheckUrlFile = config.age.secrets.svalbardHealthcheckUrl.path;
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11";
}

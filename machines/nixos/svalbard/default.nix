{ config, pkgs, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-config.nix
    ./disk-config.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  bootDiskGB = {
    enable = true;
    diskPath = "/dev/disk/by-id/ata-KINGSTON_SKC400S37128G_50026B7267043399";
  };

  networking = {
    hostName = "svalbard";
    hostId = "08680d59"; # for ZFS
    firewall.enable = false;
    wireless.enable = false;
    networkmanager.enable = false;
  };

  # ZFS Settings
  environment.systemPackages = with pkgs; [ zfs ];

  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
      pools = [ "zstorage" ];
    };
    trim = {
      enable = true;
      interval = "monthly";
    };
  };

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;

  # Healthcheck Ping
  systemd = {
    timers."healthcheck-uptime" = {
      description = "Healthcheck Ping";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "betteruptime.service";
      };
    };
    services."betteruptime" = {
      description = "Better Uptime Healthcheck";
      script = ''
        ${pkgs.curl}/bin/curl -fsSL $(cat ${config.age.secrets.svalbardHealthcheckUrl.path})
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
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

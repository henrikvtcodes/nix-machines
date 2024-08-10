{ pkgs, config, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-config.nix
    ./metrics
  ];

  networking.hostName = "valcour";
  networking.hostId = "5af035d8";

  boot.loader.systemd-boot.enable = true;
  # boot.loader.systemd-boot.bootCounting = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.firewall.enable = false;
  networking.wireless.enable = false;
  networking.networkmanager.enable = false;

  bootDisk = {
    enable = true;
    diskPath = "/dev/disk/by-id/nvme-KXG50ZNV256G_NVMe_TOSHIBA_256GB_687F729NFANP";
  };

  # Healthcheck Ping
  age.secrets.valcourHealthcheckUrl.file = ../../../secrets/valcourHealthcheckUrl.age;
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
        ${pkgs.curl}/bin/curl -fsSL $(cat ${config.age.secrets.valcourHealthcheckUrl.path})
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
  system.stateVersion = "23.11";
}

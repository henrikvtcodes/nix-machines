{ ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-config.nix
    ./services
  ];

  networking.hostName = "marstrand";
  # networking.hostId = "";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  bootDiskGB = {
    enable = true;
    diskPath = "/dev/disk/by-id/ata-Timetec_35TTM8SSATA-128G_PL220927YSC128G0103";
  };

  networking.firewall.enable = false;
  networking.wireless.enable = false;
  networking.networkmanager.enable = false;

  svcs.tailscale.advertiseExitNode = true;

  services.prometheus.exporters.node.enable = true;
  age.secrets.ciAgentSecrets.file = ../../../secrets/ciAgentSecrets.age;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05";
}

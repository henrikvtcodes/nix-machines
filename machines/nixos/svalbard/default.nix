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
    ./disk-config.nix
  ];

  bootDisk = {
    enable = true;
    diskPath = "/dev/disk/by-id/ata-KINGSTON_SKC400S37128G_50026B7267043399";
  };

  environment.systemPackages = with pkgs; [ zfs ];

  networking.hostName = "svalbard";
  networking.hostId = "738195cd"; # for ZFS

  networking.firewall.enable = false;
  networking.wireless.enable = false;
  networking.networkmanager.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11";
}

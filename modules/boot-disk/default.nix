{ config, lib, ... }:

with lib;
let
  cfg = config.bootDisk;
in
{
  options.bootDisk = {
    enable = mkEnableOption "Enable boot disk";
    diskPath = mkOption {
      type = types.path;
      description = ''
        The path to the boot disk.
      '';
    };
    # swap = {
    #   enable = mkEnableOption "Enable swap";
    #   size = mkOption {
    #     type = types.enum [
    #       "512M"
    #       "1G"
    #       "2G"
    #       "4G"
    #       "8G"
    #     ];
    #     default = "2G";
    #     description = ''
    #       The size of the swap partition.
    #     '';
    #   };
    # };
  };

  config = mkIf cfg.enable {
    disko.devices.disk.main = {
      type = "disk";
      device = cfg.diskPath;
      name = "main";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1M";
            type = "EF02"; # for grub MBR
            priority = 1; # Needs to be first partition
          };
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
          # swap = mkIf cfg.swap.enable {
          #   size = cfg.swap.size;
          #   content = {
          #     type = "swap";
          #   };
          # };
        };
      };
    };
  };
}

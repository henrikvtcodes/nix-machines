{ config, lib, ... }:

# This modules defines the same options (but in a diff namespace) as the other one, but it partions the disk without the grub MBR partition.
# I don't know why I did that earlier. 

with lib;
let
  cfg = config.bootDiskGB;
in
{
  options.bootDiskGB = {
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
          ESP = {
            type = "EF00";
            size = "500M";
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

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  # Shorter name to access final settings a 
  # user of hello.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.bootDisk;
in
{
  # Declare what settings a user of this "hello.nix" module CAN SET.
  options.bootDisk = {
    enable = mkEnableOption "hello service";
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

  # Define what other settings, services and resources should be active IF
  # a user of this "hello.nix" module ENABLED this module 
  # by setting "services.hello.enable = true;".
  config = mkIf cfg.enable {
    disko.devices.disk.boot = {
      type = "disk";
      device = cfg.diskPath;
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

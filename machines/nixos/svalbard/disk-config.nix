{
  disko.devices = {
    disk = {
      # --------- ZFS Mass Storage Disks ---------
      # hdd1 = {
      #   type = "disk";
      #   device = "/dev/disk/by-id/ata-TOSHIBA_MG04ACA400N_38CXK3V5FSYC";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       zfs = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "zstorage";
      #         };
      #       };
      #     };
      #   };
      # };
      # hdd2 = {
      #   type = "disk";
      #   device = "/dev/disk/by-id/ata-TOSHIBA_MG04ACA400N_38DEK8WVFSYC";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       zfs = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "zstorage";
      #         };
      #       };
      #     };
      #   };
      # };
      # --------- NVMe Cache/Storage Disks ---------
      nvme1 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-KXG50ZNV256G_TOSHIBA_Y7UF724WF6FS";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    # --------- ZFS Pools ---------
    zpool = {
      # # Mass storage mirror pool
      zpool = {
      zroot = {
        type = "zpool";
        mode = "";
        mountpoint = "/";
        rootFsOptions = {
          compression = "zstd";
        };

        datasets = {
          "root" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/";
          };
          "root/nix" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/nix";
          };
          "root/var" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/var";
          };
        };
      };      
    };

      # zstorage = {
      #   type = "zpool";
      #   mode = "mirror";
      #   mountpoint = "/data/storage";
      #   rootFsOptions = {
      #     compression = "zstd";
      #   };

      #   datasets = {
      #     backup = {
      #       type = "zfs_fs";
      #       options.mountpoint = "/data/storage/backup";
      #     };
      #     media = {
      #       type = "zfs_fs";
      #       options.mountpoint = "/data/storage/media";
      #     };
      #     apps = {
      #       type = "zfs_fs";
      #       options.mountpoint = "/data/storage/apps";
      #     };
      #   };
      # };      
    };
  };
}

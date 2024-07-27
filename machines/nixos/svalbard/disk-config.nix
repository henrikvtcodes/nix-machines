{
  disko.devices = {
    disk = {
      # --------- Boot Disk ---------
      # main = {
      #   type = "disk";
      #   device = "/dev/disk/by-id/ata-KINGSTON_SKC400S37128G_50026B7267043399";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       boot = {
      #         size = "1M";
      #         type = "EF02"; # for grub MBR
      #         priority = 1; # Needs to be first partition
      #       };
      #       ESP = {
      #         size = "512M";
      #         type = "EF00";
      #         content = {
      #           type = "filesystem";
      #           format = "vfat";
      #           mountpoint = "/boot";
      #         };
      #       };
      #       root = {
      #         size = "100%";
      #         content = {
      #           type = "filesystem";
      #           format = "ext4";
      #           mountpoint = "/";
      #         };
      #       };
      #     };
      #   };
      # };
      # --------- ZFS Mass Storage Disks ---------
      hdd1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-TOSHIBA_MG04ACA400N_38CXK3V5FSYC";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zstorage";
              };
            };
          };
        };
      };
      hdd2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-TOSHIBA_MG04ACA400N_38DEK8WVFSYC";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zstorage";
              };
            };
          };
        };
      };
      # --------- NVMe Cache/Storage Disks ---------
      nvme1 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-KXG50ZNV256G_TOSHIBA_Y7UF724WF6FS";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zapps";
              };
            };
          };
        };
      };
    };
    # --------- ZFS Pools ---------
    zpool = {
      # Mass storage mirror pool
      zstorage = {
        type = "zpool";
        mode = "mirror";
        mountpoint = "/mnt/storage";
        rootFsOptions = {
          compression = "zstd";
        };

        datasets = {
          backup = {
            type = "zfs_fs";
            mountpoint = "/mnt/storage/backup";
          };
          media = {
            type = "zfs_fs";
            mountpoint = "/mnt/storage/media";
          };
          apps = {
            type = "zfs_fs";
            mountpoint = "/mnt/storage/apps";
          };
        };
      };
      # Application (ie high speed) storage "pool"
      zapps = {
        type = "zpool";
        mode = "";
        mountpoint = "/mnt/apps";
        rootFsOptions = {
          compression = "zstd";
        };

        datasets = {
          main = {
            type = "zfs_fs";
            mountpoint = "/mnt/apps/main";
          };
          scratch = {
            type = "zfs_fs";
            mountpoint = "/mnt/apps/scratch";
          };
        };
      };
    };
  };

}

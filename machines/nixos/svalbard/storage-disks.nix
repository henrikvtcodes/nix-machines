{
  disko.devices = {
    disk = {
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

      scratch1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-KINGSTON_SKC400S37128G_50026B7267043399";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zscratch";
              };
            };
          };
        };
      };
    };

    # --------- ZFS Pools ---------
    zpool = {
      zstorage = {
        type = "zpool";
        mode = "mirror";
        mountpoint = "/data/storage";
        rootFsOptions = {
          compression = "zstd";
        };

        datasets = {
          backup = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/mnt/storage/backups";
          };
          media = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/mnt/storage/apps";
          };
          apps = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/mnt/storage/apps";
          };
        };
      };

      zscratch = {
        type = "zpool";
        rootFsOptions = {
          compression = "zstd";
        };

        datasets = {
          backup = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/mnt/scratch/backups";
          };
          apps = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/mnt/scratch/apps";
          };
        };
      };
    };
  };
}

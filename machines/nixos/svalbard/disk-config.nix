{
  boot.zfs.extraPools = ["zstorage" "zapps"];
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
        mountpoint = "/data/storage";
        rootFsOptions = {
          compression = "zstd";
        };

        datasets = {
          backup = {
            type = "zfs_fs";
            options.mountpoint = "/data/storage/backup";
          };
          media = {
            type = "zfs_fs";
            options.mountpoint = "/data/storage/media";
          };
          apps = {
            type = "zfs_fs";
            options.mountpoint = "/data/storage/apps";
          };
        };
      };
      # Application (ie high speed) storage "pool"
      zapps = {
        type = "zpool";
        mode = "";
        mountpoint = "/data/apps";
        rootFsOptions = {
          compression = "zstd";
        };

        datasets = {
          main = {
            type = "zfs_fs";
            options.mountpoint = "/data/apps/main";
          };
          scratch = {
            type = "zfs_fs";
            options.mountpoint = "/data/apps/scratch";
          };
          prometheus = {
            type = "zfs_fs";
            options.mountpoint = "/var/lib/prometheus";
          };
        };
      };
    };
  };
}

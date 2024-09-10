{
  disko.devices = {
    disk = {
      nvme1 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-KLEVV_CRAS_C710_M.2_NVMe_SSD_256GB_2023103001001506";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zdata";
              };
            };
          };
        };
      };
    };
    # --------- ZFS Pools ---------
    zpool = {
      zdata = {
        type = "zpool";
        mode = "";
        rootFsOptions = {
          compression = "zstd";
        };

        datasets = {
          main = {
            type = "zfs_fs";
            options.mountpoint = "/data/main";
          };
          # prometheus = {
          #   type = "zfs_fs";
          #   options.mountpoint = "/var/lib/prometheus";
          # };
        };
      };
    };
  };

}

# svalbard

svalbard is my primary server box at the moment. it contains two ssds and two 4tb drives - more detailed specs below.

**I also wrote a blog post abt this machine:** https://blog.henrikvt.com/building-a-sub-200-4tb-nas

## specs

### the system

| thing       | description                     |
| ----------- | ------------------------------- |
| Base system | HP EliteDesk 800 G3 SFF         |
| CPU         | Intel Core i5 6500t (4c/4t)     |
| RAM         | 16GB (2x 8GB) SKHynix DDR4 2666 |

### drives & partitions

| Drive                  | ID  | Capacity | Purpose                          |
| ---------------------- | --- | -------- | -------------------------------- |
| SanDisk SATA3 SSD      |     | 120GB    | Boot drive                       |
| Toshiba M.2 PCIe NVMe  |     | 256GB    | ARC cache + higher speed storage |
| Toshiba Enterprise HDD |     | 4TB      | (x2 drives) Mass storage         |

These drives are configured as follows. The boot ssd contains only the boot partition and 4GB swap.
It only stores config stuff, nix store, system logs, etc.
The NVMe drive has a couple partitions: a 64GB partition, set up as an L2 ARC cache for the ZFS mass storage. It is configured this way because having too much L2 ARC increases ZFS' ram usage. Partition two is the remaining storage (~192GB minus formatting losses) and is used as a higher speed access storage for apps I'm running like Jellyfin, Immich, Grafana/Prometheus/Loki/Mimir, etc.
At some point this will be moved to a ZFS mirror of two larger NVMe drives on a PCIe card, but my wallet is beat up enough already.
Finally, the two HDDs are configured in a ZFS mirror for redundancy.

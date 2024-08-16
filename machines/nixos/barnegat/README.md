## Setup Notes

```sh
systemctl stop dhcpcd
systemctl stop resolvconf
ip address add 162.120.71.172/24 broadcast 162.120.71.255 dev ens3
ip route add default via 162.120.71.1 dev ens3 proto static metric 100
echo -e "nameserver 9.9.9.10\nnameserver 149.112.112.10" >> /etc/resolv.conf
mkdir ~/.ssh && echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINimhbJZN+MLdXbtk3Mrb5dca7P+LKy399OqqYZ122Ml" >> ~/.ssh/authorized_keys
ping -c 5 github.com
```

### Filesystem manual stuff

```sh
fdisk /dev/vda
sudo mkfs.fat -F 32 /dev/vda1
fatlabel /dev/vda1 NIXBOOT
mkfs.ext4 /dev/vda2 -L NIXROOT
mount /dev/disk/by-label/NIXROOT /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/NIXBOOT /mnt/boot
nixos-generate-config --root /mnt
```

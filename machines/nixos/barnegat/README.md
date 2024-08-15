### Setup Instructions

```sh
dhcpcd
ip a
fdisk /dev/vda
sudo mkfs.fat -F 32 /dev/vda1
fatlabel /dev/vda1 NIXBOOT
mkfs.ext4 /dev/vda2 -L NIXROOT
mount /dev/disk/by-label/NIXROOT /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/NIXBOOT /mnt/boot
nixos-generate-config --root /mnt
```

```sh
cat /mnt/etc/nixos/configuration.nix
cat /mnt/etc/nixos/hardware-configuration.nix
nixos-install --root /mnt --option substitute false
nixos-install --root /mnt --option binary-caches ""
vi /mnt/etc/nixos/configuration.nix
ip a
vi /mnt/etc/nixos/configuration.nix
nixos-install --root /mnt --option binary-caches ""
cd /mnt
nixos-rebuild test
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
ping github.com
ping 1.1.1.1
systemctl status resolvconf.service
vi /etc/resolv.conf
```

```sh
systemctl stop dhcpcd
ip address add 162.120.71.172/24 broadcast 162.120.71.255 dev ens3
ip route add default via 162.120.71.1 dev ens3 proto static metric 100
ping -c 10 9.9.9.9
vi /etc/resolv.conf
rm -f /etc/resolv.conf
echo -e "nameserver 9.9.9.10\nnameserver 149.112.112.10" >> /etc/resolv.conf
systemctl status resolvconf.service
systemctl restart resolvconf.service
systemctl status resolvconf.service
ping google.com
passwd
ip a
curl https://henrikvt.com/id_ed25519.pub >> ~/.ssh/authorized_keys
mkdir ~/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINimhbJZN+MLdXbtk3Mrb5dca7P+LKy399OqqYZ122Ml" >> ~/.ssh/authorized_keys
history
history >> /history.txt
```

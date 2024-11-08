# Managing NixOS Machines

## Set up Git-over-SSH

1.  vi `.ssh/config` and add the following:

```
Host github.com
  AddKeysToAgent yes
  IgnoreUnknown UseKeychain
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
```

2. Create & secure private key file: `touch ~/.ssh/id_ed25519 && chmod 600 ~/.ssh/id_ed25519`
3. Add private key: `vi ~/.ssh/id_ed25519`
4. Add keys to agent: `ssh-add`
5. Test authentication: `ssh -T git@github.com`

## Installing a new machine

https://nixos.asia/en/nixos-install-disko

1. _On the machine:_ Get the latest minimal ISO from https://nixos.org/download/ and boot into it
2. _On the machine:_ Login as root `sudo su root`
3. _On the machine:_ Set password using `passwd`
4. _On the machine:_ Find IP address using `ip a`
5. _On your laptop:_ Log into the machine `ssh root@<ip>` (entering password as necessary)
6. _via SSH_: Download the base disko config: `curl https://raw.githubusercontent.com/henrikvtcodes/nix-machines/main/init/disk-config.nix -o /tmp/disk-config.nix`
7. Edit disk config to add the correct disk: `vi /tmp/disk-config.nix`
8. Mount the boot disk: `nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disk-config.nix`
9. Generate config and move disk config into the nixos config directory: `nixos-generate-config --no-filesystems --root /mnt  && cp /tmp/disk-config.nix /mnt/etc/nixos/disk-config.nix`
10. Replace generated config with our config: `curl -o /mnt/etc/nixos/configuration.nix https://raw.githubusercontent.com/henrikvtcodes/nix-machines/main/init/configuration.nix`
11. Install the system: `nixos-install --root /mnt` (Set the root password as necessary)

## ZFS Storage

_Follow install steps above_

1. Copy the disko config _for the ZFS disks only_ to /etc/nixos/zfsdisks.nix
2. Run `nix run github:nix-community/disko -- --mode disko /etc/nixos/zfsdisks.nix` (This wipes, reformats, and mounts the disks)
3. Check pools: `zpool list` and then export them: `zpool export -a`
4. Reboot!

## Deploy a config

```sh
sudo nixos-rebuild test --flake github:henrikvtcodes/nix-machines#<hostname>
```

where `<hostname>` is the hostname of the machine to deploy

## Manually checking and cleaning up old generations

#### List generations

```sh
nix profile history --profile /nix/var/nix/profiles/system
# Docs
man nix3-profile-history
```

#### Delete Generations

```sh
sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 14d
# Docs
man nix3-profle-wipe-history
```

#### No Space on Boot Partition  
Run this command as root:  
```sh
nix-collect-garbage -d
```
https://discourse.nixos.org/t/no-space-left-on-boot/24019/7  

## `chroot`-ing

1. Boot into the NixOS minimal image on a flashdrive and switch to root `sudo su`
2. Download the disk config from the init folder (`curl -o /tmp/disk-config.nix https://raw.githubusercontent.com/henrikvtcodes/nix-machines/main/init/disk-config.nix`) to `/tmp/disk-config.nix`. Ensure that the device path is correct.
   _If the system has a non-standard config, make sure to download that one!_
3. Run `nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode mount /tmp/disk-config.nix`. This will **_mount_** the disk - not format or wipe it, importantly.
4. Run `nixos-enter`. Now you're free to do whatever you need as root!

https://nixos.wiki/wiki/Change_root

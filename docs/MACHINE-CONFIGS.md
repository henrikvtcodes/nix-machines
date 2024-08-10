# Machine Configs

## NixOS

### Creating a new config

1. Create a directory under `/machines/nixos/<hostname>`
2. Create a `default.nix` file (just copy another one and change the values)  
   Make sure to set the hostname and remove any

### First install of a config

1. Add private key under `/home/henrikvt/.ssh/id_ed25519`
2. Ensure the machine's host key (`cat /etc/ssh/ssh)

### ZFS

Required options:

```nix
{
boot.supportedFilesystems = [ "zfs" ];
boot.zfs.forceImportRoot = false;
}
```

#### Generating a hostId

Run `head -c 8 /etc/machine-id`

Set the option:

```nix
{
networking.hostId = "8charid";
}
```

#### Preventing boot issues

_Without using legacy mode_

##### In datasets

https://github.com/nix-community/disko/issues/581

Instead of

```nix
{
            data = {
            type = "zfs_fs";
            mountpoint = "/zstorage/data";
          };
}
```

do

```nix
{
            data = {
            type = "zfs_fs";
            options.mountpoint = "/zstorage/data";
          };
}
```

This prevents a situation where both systemd and zfs try to auto-mount during boot.

#### If there is a problem (Emergency Shell Commands)

https://github.com/nix-community/disko/issues/359

```sh

mount -a

systemctl default
```

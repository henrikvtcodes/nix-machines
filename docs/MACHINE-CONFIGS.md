# Machine Configs

## NixOS

### Installing a new config

**Reccomended First Step:** Install the machine according to the [NixOS guide](/docs/NIXOS.md)

1. Create a directory under `/machines/nixos/<hostname>`
2. Create a `default.nix` file (just copy another one and change the values)  
   Make sure to set the hostname and remove any

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

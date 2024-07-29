# Machine Configs

## NixOS

### Installing a new config

**Reccomended First Step:** Install the machine according to the [NixOS guide](/docs/NIXOS.md)

1. Create a directory under `/machines/nixos/<hostname>`
2. Create a `default.nix` file (just copy another one and change the values)  
   Make sure to set the hostname and remove any

### ZFS

#### Generating a hostId

Run `head -c 12 /etc/machine-id`

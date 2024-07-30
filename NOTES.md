# Notes on Nix, Flakes, NixOS

Useful findings and resources as I fall down the wormhole

# Tips

**Nix cant find file?**
`nix flake check --repair`

# Links

## secrets (agenix)

- useful tutorial: https://blog.sekun.net/posts/manage-secrets-in-nixos/  
  worth noting
- https://lgug2z.com/articles/handling-secrets-in-nixos-an-overview/
- https://lgug2z.com/articles/providing-runtime-secrets-to-nixos-services/
- https://github.com/yaxitech/ragenix

## general linux stuff

- [swap size](https://itsfoss.com/swap-size/)

## tutorial sites

- https://nixos-and-flakes.thiscute.world
- https://zero-to-nix.com/

## documentation search

- https://home-manager-options.extranix.com/
- https://github.com/nix-community/manix

## youtube

### channels

- https://www.youtube.com/@vimjoyer/videos
- https://www.youtube.com/@IogaMaster

### videos/playlists

- https://www.youtube.com/playlist?list=PL-saUBvIJzOkjAw_vOac75v-x6EzNzZq- (howto playlist from 2021)
- https://www.youtube.com/watch?v=uS8Bx8nQots (zaney video)
- https://www.youtube.com/watch?v=nLwbNhSxLd4 (full tutorial)
- https://www.youtube.com/watch?v=YPKwkWtK7l0 (impermanence)
- https://www.youtube.com/watch?v=bV3hfalcSKs (config modularity)
- https://www.youtube.com/watch?v=a67Sv4Mbxmc (vimjoyer aio guide)
- https://www.youtube.com/watch?v=Q-QPtHrvLB0 (iogamaster nixos servers video)

## other

- https://mynixos.com
- https://garnix.io/

## blog posts

- https://grahamc.com/blog/erase-your-darlings/
- https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/
- https://www.return12.net/posts/bootstrapping-nixos/
- https://klarasystems.com/articles/openzfs-all-about-l2arc/ **(ZFS L2 ARC)**

## configs to reference

- https://github.com/jakehamilton/config
- https://github.com/dustinlyons/nixos-config
- https://github.com/ryan4yin/nix-config
- https://github.com/lovesegfault/nix-config
- https://github.com/notusknot/dotfiles-nix
- https://github.com/notthebee/nix-config
- https://github.com/Misterio77/nix-config
- https://github.com/IogaMaster/dotfiles
- https://github.com/hlissner/dotfiles
- https://github.com/librephoenix/nixos-config
- https://gitlab.com/Zaney/zaneyos

### useful libraries/repos

- https://github.com/nix-systems/nix-systems
- https://github.com/nix-community/home-manager
- https://github.com/yaxitech/ragenix (rust rewrite of agenix)
- https://snowfall.org/
- https://github.com/nix-community/disko
- https://github.com/serokell/deploy-rs
- https://github.com/nix-community/haumea
- https://github.com/rust-motd/rust-motd (not strictly nix related, but useful nonetheless)

# `nix-machines`

this contains configurations for my nixos (and hopefully darwin in the future) machines.

> [!WARNING]
> I am very new to Nix and NixOS. This config is not a good reference to learn from.

#### [Docs](/docs/README.md)

#### Secrets

The docs do expand on this but: this is structured with the assumption that creating/editing secrets happens only in the `secrets` submodule/directory.

## Things to know

That namespace `svcs.` is all my custom services, as defined in `modules`

## LSP

```sh
nix profile install github:nixos/nixpkgs#nixd
```

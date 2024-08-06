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

**_NOT DONE_**

1. _On the machine:_ Get the latest minimal ISO from https://nixos.org/download/ and boot into it
2. _On the machine:_ Set password using `passwd`ls /
3. _On the machine:_ Find IP address using `ip a`
4. _On your laptop:_ Log into the machine `ssh nixos@<ip here>`
5. _via SSH_: Generate the base config `curl https://raw.githubusercontent.com/henrikvtcodes/nix-machines/main/init/init.sh | bash`

## Deploy a config

```sh
sudo nixos-rebuild test --flake github:henrikvtcodes/nix-machines#<hostname>
```

where `<hostname>` is the hostname of the machine to deploy

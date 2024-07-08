# Secrets

How to handle creating, updating, and using secrets in this repository.

### Prerequisites

- agenix: https://github.com/ryantm/agenix (this flake uses [ragenix](https://github.com/yaxitech/ragenix) as a drop-in substitute)
- Access to https://github.com/henrikvtcodes/nix-secrets repo

#### Set up the submodule

[Set up Git-over-SSH](/docs/NIXOS.md#set-up-git-over-ssh) and then run
`git submodule init && git submodule update`

> [!NOTE]
> All `agenix` operations must happen inside the `secrets` folder: `cd secrets`

## Keys

Keys determine who can decrypt a given secret. Each secret gets assigned a nix "set" of SSH public keys that can access the secret.

> [!WARNING]
> In order to edit or rekey a secret, a private key that corresponds to an existing public key with access to that secret must be present at `~/.ssh/id_ed25519` (bc RSA keys are mid). If on NixOS, ensure that the system host key is part of the keys allowed to access required secrets.

## Secrets

**Example Name:** `mysecret`

### Creating a secret

1. Create the secret entry in `secrets.nix`: `"mysecret.age".publicKeys = all;`
2. Create & encrypt the secret: `agenix -e mysecret.age`
3. Register the secret for Nix to use in `default.nix`: `age.secrets.mysecret.file = "henrikUserPassword.age";`
4. Commit to secrets repo & update submodule in main repo

### Editing a secret

1. Edit & re-encrypt the secret: `agenix -e mysecret.age`
2. Commit to secrets repo & update submodule in main repo

### Referencing a secret

Example: a user password

```nix
{
  users.users.user1 = {
    isNormalUser = true;
    # .path gives the path to the decrypted secret
    passwordFile = config.age.secrets.mysecret.path;
  };
}
```

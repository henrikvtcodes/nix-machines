{
  config,
  pkgs,
  lib,
  ...
}:
{
  age.identityPaths = lib.mkDefault [ "~/.ssh/id_ed25519" ];

  age.secrets.tailscaleAuthKey.file = ./tailscaleAuthKey.age;
  age.secrets.henrikUserPassword.file = ./henrikUserPassword.age;
}

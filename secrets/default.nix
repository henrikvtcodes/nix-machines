{
  config,
  pkgs,
  lib,
  ...
}:
{
  age.secrets.tailscaleAuthKey.file = ./tailscaleAuthKey.age;
  age.secrets.henrikUserPassword.file = ./henrikUserPassword.age;
}

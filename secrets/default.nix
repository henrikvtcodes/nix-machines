{
  config,
  pkgs,
  lib,
  ...
}:
{
  age.secrets.tailscaleAuthKey.file = ./tailscaleAuthKey.age;
  age.secrets.henrikUserPassword.file = ./henrikUserPassword.age;
  age.secrets.svalbardHealthcheckUrl.file = ./svalbardHealthcheckUrl.age;
  age.secrets.valcourHealthcheckUrl.file = ./valcourHealthcheckUrl.age;

  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
    "/etc/ssh/ssh_host_rsa_key"
  ];
}

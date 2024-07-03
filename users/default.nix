{ pkgs, ... }:
{
  nix.settings.trusted-users = [ "henrikvt" ];

  # NixOS User Config
  users = {
    users.henrikvt = {
      uid = 1000;
      group = "henrikvt";
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
      ];

      shell = pkgs.zsh;
    };

    groups.henrikvt = {
      gid = 1000;
    };
  };
}

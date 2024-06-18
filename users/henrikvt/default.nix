{
  config,
  pkgs,
  lib,
  ...
}:
{
  nix.settings.trusted-users = [ "henrikvt" ];

  users = {
    users = {
      shell = pkgs.zsh;
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
    };
  };

  programs.zsh.enable = true;
}

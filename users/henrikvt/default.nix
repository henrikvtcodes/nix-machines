{
  config,
  pkgs,
  lib,
  system,
  ...
}:
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
      packages = with pkgs; [
        # stuff
        neofetch
        neovim
        btop

        bat
        fzf
        jq
        yq

        # fun
        cowsay
        fortune
      ];
    };

    groups.henrikvt = {
      gid = 1000;
    };
  };

  programs.zsh.enable = true;
}

{
  config,
  pkgs,
  lib,
  system,
  ...
}:
{
  # nix.settings.trusted-users = [ "henrikvt" ];

  # NixOS User Config
  # users = {
  #   users.henrikvt = {
  #     uid = 1000;
  #     group = "henrikvt";
  #     isNormalUser = true;
  #     extraGroups = [
  #       "wheel"
  #       "networkmanager"
  #     ];

  #     shell = pkgs.zsh;
  #   };

  #   groups.henrikvt = {
  #     gid = 1000;
  #   };
  # };

  imports = [
    ./editor.nix
    ./zsh.nix
    ./git.nix
  ];

  programs.home-manager.enable = true;

  # home-manager user config
  home = {
    username = "henrikvt";
    homeDirectory = "/home/henrikvt";
    # stateVersion = system.stateVersion;
    packages = with pkgs; [
      ffmpeg
      yt-dlp
    ];
  };
}

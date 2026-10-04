{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../modules/darwin
    ../../home/henrikvt
  ];

  nixpkgs.config.allowUnfree = true;

  # TouchID Prompt for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  home.henrikvt.enable = true;

  # Show hidden files in Finder always
  system.defaults.finder.AppleShowAllFiles = true;

  environment.systemPackages = with pkgs; [iproute2mac];
}

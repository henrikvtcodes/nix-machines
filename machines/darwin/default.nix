{
  pkgs,
  lib,
  ...
}: let
  # mtr-packet opens the raw sockets, so it is the only part that needs root.
  # Nix store files can't be setuid, so activation copies it to a fixed path.
  suidPacket = "/usr/local/libexec/mtr-packet";
  mtrWrapper = pkgs.writeShellScriptBin "mtr" ''
    MTR_PACKET=${suidPacket} exec ${pkgs.mtr}/bin/mtr "$@"
  '';
in {
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

  environment.systemPackages = [pkgs.iproute2mac mtrWrapper];

  # setuid copy of mtr-packet, executable by admin users only
  system.activationScripts.postActivation.text = ''
    install -d -m 755 -o root -g wheel /usr/local/libexec
    install -m 4750 -o root -g admin ${pkgs.mtr}/bin/mtr-packet ${suidPacket}
  '';
}

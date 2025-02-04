{
  lib,
  pkgs,
  ...
}: let
  launchdWeekly = {
    Hour = 3;
    Minute = 0;
    Weekday = 0;
  };
in {
  imports = [
    ../../modules/darwin
    ../../home/henrikvt
  ];

  # Clean up nix store + old generations automatically
  nix = {
    package = pkgs.nix;
    gc = {
      automatic = true;
      interval = launchdWeekly;
      options = "--delete-older-than 7d";
    };
    optimise = {
      automatic = true;
      interval = launchdWeekly;
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "recursive-nix"
      ];
      system-features = ["recursive-nix"];
    };
  };

  # TouchID Prompt for sudo
  security.pam.enableSudoTouchIdAuth = true;

  home.henrikvt.enable = true;

  # Show hidden files in Finder always
  system.defaults.finder.AppleShowAllFiles = true;

  # Force the nix daemon to run
  services.nix-daemon.enable = lib.mkForce true;
}

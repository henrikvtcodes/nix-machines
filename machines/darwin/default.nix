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
      extra-substituters = ["https://nix-community.cachix.org"];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    };
  };

  # TouchID Prompt for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  home.henrikvt.enable = true;

  # Show hidden files in Finder always
  system.defaults.finder.AppleShowAllFiles = true;
}

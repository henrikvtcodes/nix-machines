{
  config,
  pkgs,
  lib,
  ...
}: {
  nix = lib.mkForce {enable = false;};

  determinateNix = {
    enable = true;

    customSettings = {
      experimental-features = "nix-command flakes recursive-nix";
      system-features = "recursive-nix";
      extra-substituters = "https://nix-community.cachix.org";
      extra-trusted-public-keys = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
      auto-optimise-store = true; # stands in for nix.optimise
    };

    # replaces nix.gc, but not on equal terms — see below
    determinateNixd.garbageCollector.strategy = "automatic"; # or "disabled"
  };

  system.primaryUser = "henrikvt";
  users.users.henrikvt = {
    home = "/Users/henrikvt";
    packages = with pkgs; [
      nixd
      just
      kraft
      uv
      gdu
      diskus
      fnm
      flyctl
      qrcp
      statix
      yt-dlp
      pipes
      speedtest-cli
      nmap
      doggo
      cmake
      safe-rm
      mtr
      nh
      cocoapods
      fastlane
    ];
  };

  environment = {
    shellAliases = {
      # rebuild = "${lib.getExe pkgs.nh} darwin switch && omz reload";
      reload = "omz reload";
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
      ts = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
    };

    systemPackages = with pkgs; [attic-client];

    variables = {
      EDITOR = "nvim";
      _ZO_DATA_DIR = "/Users/henrikvt/.zoxide";
      # _ZO_EXCLUDE_DIRS = "$HOME:$HOME/wpilib/**/*";
      # JETBRAINS_BIN_DIR = "$HOME/Library/Application\ Support/JetBrains/Toolbox/scripts";
      CARGO_BIN_DIR = "$HOME/.cargo/bin";
      FNM_COREPACK_ENABLED = "true";
      FNM_RESOLVE_ENGINES = "true";
      # GITLAB_TOKEN = "$(cat ${config.age.secrets.uvmGitlabToken.path})";
      # GITLAB_HOST = "gitlab.uvm.edu";
      # NH_FLAKE = "/Users/henrikvt/Desktop/Code/projects/nixmachines#darwinConfigurations.pepacton";
    };
  };

  # age.secrets = {
  #   uvmGitlabToken = {
  #     owner = "henrikvt";
  #     file = ../../../secrets/uvmGitlabToken.age;
  #   };
  # };

  # nix-homebrew = {
  #   enable = true;
  #   enableRosetta = true;
  #   user = "henrikvt";
  #   autoMigrate = true;
  # };

  networking = {
    hostName = "phoenicia";
    computerName = "phoeniciaMac";
    # search = [
    #   "reindeer-porgy.ts.net"
    #   "ts.unicycl.ing"
    # ];
    # # This must be set in order to set search domains above
    # # $ networksetup -listallnetworkservices
    # knownNetworkServices = [
    #   "USB 10/100/1G/2.5G LAN"
    #   "Thunderbolt Bridge"
    #   "Wi-Fi"
    #   "iPhone USB"
    #   "Tailscale"
    # ];
  };

  # Enable GitHub TUI Dashboard (doesn't work on some systems)
  home.henrikvt = {
    # ghDash = true;
    ghostty = true;
    # client = true;
    extraModules = [
      ./home.nix
    ];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = 5;
  # ======================== DO NOT CHANGE THIS ========================
}

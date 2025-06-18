# Reference: https://daiderd.com/nix-darwin/manual/index.html
{
  config,
  pkgs,
  # unstable,
  ...
}: {
  system.primaryUser = "henrikvt";
  users.users.henrikvt = {
    home = "/Users/henrikvt";
    packages = with pkgs; [
      nixd
      wifi-password
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
    ];
  };

  age.identityPaths = ["/Users/henrikvt/.ssh/id_ed25519"];

  environment = {
    shellAliases = {
      rebuild = "sudo darwin-rebuild switch --flake /Users/henrikvt/Desktop/Code/projects/nixmachines#pepacton && omz reload";
      reload = "omz reload";
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
      # docker = "/Applications/Docker.app/Contents/Resources/bin/docker";
      ytdl = "yt-dlp";
      home = "cd ~";
      nvm = "fnm";
      pn = "pnpm";
      nsl = "doggo A AAAA MX TXT";
      rm = "safe-rm";
      coder = "code . -r";
    };

    systemPackages = with pkgs; [attic-client];

    variables = {
      EDITOR = "nvim";
      _ZO_DATA_DIR = "/Users/henrikvt/.zoxide";
      _ZO_EXCLUDE_DIRS = "$HOME:$HOME/wpilib/**/*";
      JETBRAINS_BIN_DIR = "$HOME/Library/Application\ Support/JetBrains/Toolbox/scripts";
      DOCKER_BIN_DIR = "/Applications/Docker.app/Contents/Resources/bin";
      FNM_COREPACK_ENABLED = "true";
      FNM_RESOLVE_ENGINES = "true";
      GITLAB_TOKEN = "$(cat ${config.age.secrets.uvmGitlabToken.path})";
      GITLAB_HOST = "gitlab.uvm.edu";
    };
  };

  age.secrets = {
    uvmGitlabToken = {
      owner = "henrikvt";
      file = ../../../secrets/uvmGitlabToken.age;
    };
  };

  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = true;

    # User owning the Homebrew prefix
    user = "henrikvt";

    # Automatically migrate existing Homebrew installations
    autoMigrate = true;
  };

  networking = {
    hostName = "pepacton";
    search = [
      "reindeer-porgy.ts.net"
      "unicycl.ing"
    ];
    # This must be set in order to set search domains above
    # $ networksetup -listallnetworkservices
    knownNetworkServices = [
      "USB 10/100/1G/2.5G LAN"
      "Thunderbolt Bridge"
      "Wi-Fi"
      "iPhone USB"
      "Tailscale"
    ];
  };

  # Enable GitHub TUI Dashboard (doesn't work on some systems)
  home.henrikvt = {
    ghDash = true;
    ghostty = true;
    client = true;
    extraModules = [
      ./home.nix
    ];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  # ======================== DO NOT CHANGE THIS ========================
  # https://daiderd.com/nix-darwin/manual/index.html#opt-system.stateVersion
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
  # ======================== DO NOT CHANGE THIS ========================
}

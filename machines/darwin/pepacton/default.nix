# Reference: https://daiderd.com/nix-darwin/manual/index.html
{pkgs, ...}: {
  users.users.henrikvt = {
    home = "/Users/henrikvt";
    packages = with pkgs; [
      nixd
      wifi-password
      just
      kraft
      fortune
      uv
      gdu
      diskus
      fnm
      flyctl
      qrcp
      ninvaders
      statix
      yt-dlp
      wrangler
      pipes
      speedtest-cli
      nmap
      doggo
    ];
  };

  environment = {
    shellAliases = {
      rebuild = "darwin-rebuild switch --flake /Users/henrikvt/Desktop/Code/projects/nixmachines#pepacton && omz reload";
      reload = "omz reload";
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
      ytdl = "yt-dlp";
      home = "cd ~";
      nvm = "fnm";
      pn = "pnpm";
    };

    systemPackages = with pkgs; [ncurses];

    variables = {
      EDITOR = "nvim";
      _ZO_DATA_DIR = "/Users/henrikvt/.zoxide";
      _ZO_EXCLUDE_DIRS = "$HOME:$HOME/wpilib/**/*";
      JETBRAINS_BIN_DIR = "$HOME/Library/Application\ Support/JetBrains/Toolbox/scripts";
      FNM_COREPACK_ENABLED = "true";
      FNM_RESOLVE_ENGINES = "true";
    };
  };

  home-manager.users.henrikvt = {
    home.sessionPath = ["$GHOSTTY_BIN_DIR" "$HOME/.bun/bin" "$JETBRAINS_BIN_DIR" "/usr/local/go/bin" "$HOME/go/bin"];
    programs.git.extraConfig = {
      user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICM+1ip8IBO+sK8J7cOwEtA/ba+tTtPHUGYC/KW6mppU";
      gpg.format = "ssh";
      gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      commit.gpgsign = true;
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
    knownNetworkServices = [
      "USB 10/100/1G/2.5G LAN"
      "Thunderbolt Bridge"
      "Wi-Fi"
      "iPhone USB"
      "Tailscale"
      "UniFi Teleport"
      "Mullvad"
    ];
  };

  # Enable GitHub TUI Dashboard (doesn't work on some systems)
  home.henrikvt = {
    ghDash = true;
    ghostty = true;
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  # ======================== DO NOT CHANGE THIS ========================
  # https://daiderd.com/nix-darwin/manual/index.html#opt-system.stateVersion
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
  # ======================== DO NOT CHANGE THIS ========================
}

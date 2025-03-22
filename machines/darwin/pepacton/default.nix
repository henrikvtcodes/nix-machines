# Reference: https://daiderd.com/nix-darwin/manual/index.html
{
  config,
  pkgs,
  unstable,
  ...
}: {
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
      lolcat
      cmake
      nyancat
      moon-buggy
      sl
      cowsay
      unstable.podman
      unstable.podman-compose
    ];
  };

  age.identityPaths = ["/Users/henrikvt/.ssh/id_ed25519"];

  environment = {
    shellAliases = {
      rebuild = "darwin-rebuild switch --flake /Users/henrikvt/Desktop/Code/projects/nixmachines#pepacton && omz reload";
      reload = "omz reload";
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
      ytdl = "yt-dlp";
      home = "cd ~";
      nvm = "fnm";
      pn = "pnpm";
      nsl = "doggo A AAAA MX TXT";
    };

    systemPackages = with pkgs; [ncurses];

    variables = {
      EDITOR = "nvim";
      _ZO_DATA_DIR = "/Users/henrikvt/.zoxide";
      _ZO_EXCLUDE_DIRS = "$HOME:$HOME/wpilib/**/*";
      JETBRAINS_BIN_DIR = "$HOME/Library/Application\ Support/JetBrains/Toolbox/scripts";
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

  home-manager.users.henrikvt = {
    home.sessionPath = ["$GHOSTTY_BIN_DIR" "$HOME/.bun/bin" "$JETBRAINS_BIN_DIR" "/usr/local/go/bin" "$HOME/go/bin"];
    programs.git.extraConfig = {
      user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICM+1ip8IBO+sK8J7cOwEtA/ba+tTtPHUGYC/KW6mppU";
      gpg.format = "ssh";
      gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      gpg.ssh.allowedSignersFile = toString ./signers.txt;
      commit.gpgsign = true;
    };

    xdg.configFile."glab-cli/config-base.yml" = let
      yaml = pkgs.formats.yaml {};
    in {
      source = yaml.generate "config.yml" {
        git_protocol = "ssh";
        check_update = false;
        host = "gitlab.uvm.edu";
        editor = "nvim";
        glamour_style = "dark";
        no_prompt = false;
        hosts = {
          "gitlab.uvm.edu" = {
            api_host = "gitlab.uvm.edu";
            api_protocol = "https";
            git_protocol = "ssh";
            user = "henrikvtcodes";
            # token = builtins.readFile config.age.secrets.uvmGitlabToken.path;
          };
          "gitlab.com" = {
            api_host = "gitlab.com";
            api_protocol = "https";
            git_protocol = "ssh";
          };
        };
      };

      onChange = ''
        rm -f ${config.home-manager.users.henrikvt.xdg.configHome}/glab-cli/config.yml
        cp ${config.home-manager.users.henrikvt.xdg.configHome}/glab-cli/config-base.yml ${config.home-manager.users.henrikvt.xdg.configHome}/glab-cli/config.yml
        chmod 600 ${config.home-manager.users.henrikvt.xdg.configHome}/glab-cli/config.yml
        echo "\n\n" > ${config.home-manager.users.henrikvt.xdg.configHome}/glab-cli/config.yml
      '';
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
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  # ======================== DO NOT CHANGE THIS ========================
  # https://daiderd.com/nix-darwin/manual/index.html#opt-system.stateVersion
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
  # ======================== DO NOT CHANGE THIS ========================
}

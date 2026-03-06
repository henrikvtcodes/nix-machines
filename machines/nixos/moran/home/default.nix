{
  lib,
  pkgs,
  unstable,
  ...
}: {
  imports = [./hypr.nix ./waybar.nix];

  home = {
    # sessionPath = ["$HOME/.bun/bin"];
    # sessionVariables = {
    #   # Bun install is self managed so I can update separately
    #   BUN_INSTALL = "$HOME/.bun";
    # };
    packages = with pkgs; [
      prismlauncher
      spotify
      networkmanagerapplet
      yaak
      uutils-coreutils-noprefix
      wireshark
      steam
      nixd
      unstable.bun

      jetbrains.idea
      jetbrains.goland
      jetbrains.webstorm
      jetbrains.datagrip
      jetbrains.pycharm
      python3

      teams-for-linux
      davinci-resolve
    ];
  };

  programs = {
    git.extraConfig = {
      user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICM+1ip8IBO+sK8J7cOwEtA/ba+tTtPHUGYC/KW6mppU";
      gpg.format = "ssh";
      gpg.ssh.program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      gpg.ssh.allowedSignersFile = ''
        commits@henrikvt.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICM+1ip8IBO+sK8J7cOwEtA/ba+tTtPHUGYC/KW6mppU
      '';
      commit.gpgsign = true;
    };
    lazygit.settings = {
      git = {
        autoFetch = false;
      };
    };

    ssh = let
      onePassPath = "~/.1password/agent.sock";
    in {
      enable = true;
      extraConfig = ''
        Host *
            IdentityAgent ${onePassPath}
        Host ashokan*
          Port 69
        Host barnegat*
          Port 69
        Host *mci*
          Port 69
        Host *.as215207.net
          User admin
      '';
    };

    firefox.enable = true;
    ghostty = {
      enable = true;
      systemd.enable = true;
      installBatSyntax = true;
      enableZshIntegration = true;
      settings = {
        font-family = "Liga SFMono Nerd Font";
        font-size = 14;
        window-padding-x = 6;
        window-inherit-font-size = false;
        theme = "Catppuccin Mocha";
        window-inherit-working-directory = true;
        working-directory = "home";
        term = "xterm-256color";
        keybind = ["alt+d=new_split:right" "alt+shift+d=new_split:down" "alt+t=new_tab" "alt+w=close_surface" "alt+c=copy_to_clipboard" "alt+v=paste_from_clipboard"];
      };
    };
    alacritty = {
      enable = true;
    };
    ncspot.enable = true;
    fuzzel = {
      enable = true;
    };
    vesktop = {
      enable = true;
      settings = {
        discordBranch = "stable";
      };
    };
    discord = {
      enable = true;
    };
    halloy = {
      enable = true;
      settings = {
        buffer.channel.topic = {
          enabled = true;
        };
        servers.ipv6 = {
          channels = [
            "#general"
          ];
          nickname = "henrikvtcodes";
          server = "irc.ipv6discord.com";
        };
      };
    };
    zed-editor = {
      enable = true;
      extensions = ["nix" "catppuccin" "vscode-icons" "discord-presence" "astro"];
    };
    hyprshot = {
      enable = true;
      saveLocation = "$HOME/Pictures/Screenshots";
    };
    satty = {
      enable = true;
    };
    thunderbird = {
      enable = true;
      profiles.henrikvt = {
        isDefault = true;
        search.default = "ddg";
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-GTK-Dark";
      package = pkgs.magnetic-catppuccin-gtk;
    };
  };

  services = {
    tailscale-systray.enable = true;
  };

  xdg.autostart = {
    enable = true;
    entries = [
      "${lib.getExe' pkgs._1password-gui "1password"}"
    ];
  };
}

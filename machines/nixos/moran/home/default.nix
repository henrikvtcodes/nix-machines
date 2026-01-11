{
  lib,
  pkgs,
  ...
}: {
  imports = [./hypr.nix ./waybar.nix];

  home = {
    sessionPath = ["$HOME/.bun/bin"];
    sessionVariables = {
      # Bun install is self managed so I can update separately
      BUN_INSTALL = "$HOME/.bun";
    };
    packages = with pkgs; [
      prismlauncher
      spotify
      networkmanagerapplet
      yaak
      uutils-coreutils-noprefix
      wireshark
      steam

      jetbrains.idea
      jetbrains.goland
      jetbrains.webstorm
      jetbrains.pycharm
      jetbrains.datagrip
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

    firefox.enable = true;
    ghostty = {
      enable = true;
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
    eww = {
      enable = false;
      configDir = ./eww;
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
      extensions = ["nix" "catppuccin" "vscode-icons"];
    };
  };

  programs.ssh = let
    onePassPath = "~/.1password/agent.sock";
  in {
    enable = true;
    extraConfig = ''
      Host *
          IdentityAgent ${onePassPath}
    '';
  };

  xdg.autostart = {
    enable = true;
    entries = [
      "${lib.getExe' pkgs._1password-gui "1password"}"
    ];
  };
}

{
  lib,
  pkgs,
  ...
}: {
  imports = [./hypr.nix ./waybar.nix];

  home.packages = with pkgs; [
    halloy
    prismlauncher
    spotify
    networkmanagerapplet
  ];

  programs = {
    git.extraConfig = {
      user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICM+1ip8IBO+sK8J7cOwEtA/ba+tTtPHUGYC/KW6mppU";
      gpg.format = "ssh";
      gpg.ssh.program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      gpg.ssh.allowedSignersFile = toString ./signers.txt;
      commit.gpgsign = true;
    };
    lazygit.settings = {
      git = {
        autoFetch = false;
      };
    };

    firefox.enable = true;
    ghostty.enable = true;
    alacritty = {
      enable = true;
      settings = {
        window = {
          startup_mode = "Fullscreen";
          dynamic_title = true;
        };
      };
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
}

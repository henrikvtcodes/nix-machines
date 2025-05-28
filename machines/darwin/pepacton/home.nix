{
  pkgs,
  config,
  lib,
  age,
  ...
}: {
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
          token = "@uvmtoken@";
        };
        "gitlab.com" = {
          api_host = "gitlab.com";
          api_protocol = "https";
          git_protocol = "ssh";
        };
      };
    };
  };

    home.activation = {
      glab = lib.hm.dag.entryAfter ["writeBoundary"] ''
        rm -f ${config.xdg.configHome}/glab-cli/config.yml
        cp ${config.xdg.configHome}/glab-cli/config-base.yml ${config.xdg.configHome}/glab-cli/config.yml
        chmod 600 ${config.xdg.configHome}/glab-cli/config.yml
        sed -i "s|@uvmtoken@|$(cat ${age.secrets.uvmGitlabToken.path})|g" ${config.xdg.configHome}/glab-cli/config.yml
      '';
    };
} 

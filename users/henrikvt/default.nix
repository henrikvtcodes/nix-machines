{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.users.henrikvt;
in {
  options.users.henrikvt = {
    enableNixosSpecific = lib.mkEnableOption "Enable NixOS specific options";
    enablePasswordFile = lib.mkEnableOption "Enable password file";
  };

  config = {
    nix.settings.trusted-users = ["henrikvt"];

    age.secrets = lib.mkIf cfg.enablePasswordFile {
      henrikUserPassword.file = ../../secrets/henrikUserPassword.age;
    };

    users = {
      users.henrikvt = {
        uid = 1000;
        group = "henrikvt";
        isNormalUser = true;
        hashedPasswordFile = lib.mkIf cfg.enablePasswordFile config.age.secrets.henrikUserPassword.path;
        extraGroups = [
          "wheel"
          "networkmanager"
          "podman"
          "traefik"
        ];

        shell = pkgs.zsh;
        packages = with pkgs;
          [
            # stuff
            fastfetch
            hyfetch
            comma
            btop

            bat
            fzf
            zoxide
            jq
            yq

            mtr

            # fun
            cowsay
            fortune
          ]
          ++ lib.lists.optional (!config.home.henrikvt.enable) pkgs.neovim;

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINimhbJZN+MLdXbtk3Mrb5dca7P+LKy399OqqYZ122Ml"
        ];
      };

      groups.henrikvt = {
        gid = 1000;
      };
    };

    programs.zsh = {
      enable = true;
      ohMyZsh = lib.mkIf (!config.home.henrikvt.enable) {
        enable = true;
        theme = "josh";
        plugins = [
          "git"
          "common-aliases"
          "sudo"
          "command-not-found"
        ];
      };
    };

    programs.ssh.startAgent = true;

    age.identityPaths = lib.mkIf cfg.enableNixosSpecific ["/home/henrikvt/.ssh/id_ed25519"];
  };
}

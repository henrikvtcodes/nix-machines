{ pkgs, config, ... }:
{
  nix.settings.trusted-users = [ "henrikvt" ];

  # NixOS User Config
  users = {
    users.henrikvt = {
      uid = 1000;
      group = "henrikvt";
      isNormalUser = true;
      hashedPasswordFile = config.age.secrets.henrikUserPassword.path;
      extraGroups = [
        "wheel"
        "networkmanager"
      ];

      shell = pkgs.zsh;
      packages = with pkgs; [
        # stuff
        neofetch
        neovim
        btop

        bat
        fzf
        jq
        yq

        # fun
        cowsay
        fortune
      ];

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINimhbJZN+MLdXbtk3Mrb5dca7P+LKy399OqqYZ122Ml"
      ];
    };

    groups.henrikvt = {
      gid = 1000;
    };
  };

  programs.zsh.enable = true;

  programs.ssh.startAgent = true;

  age.identityPaths = [
    /home/henrikvt/.ssh/id_ed25519
    /home/henrikvt/.ssh/homelab
  ];
}

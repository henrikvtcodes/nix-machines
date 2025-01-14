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
    ];
  };

  environment.shellAliases = {
    rebuild = "darwin-rebuild switch --flake /Users/henrikvt/Desktop/Code/projects/nixmachines#pepacton";
  };

  home-manager.users.henrikvt.programs.git.extraConfig = {
    user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICM+1ip8IBO+sK8J7cOwEtA/ba+tTtPHUGYC/KW6mppU";
    gpg.format = "ssh";
    gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    commit.gpgsign = true;
  };

  networking.hostName = "pepacton";

  nixpkgs.hostPlatform = "aarch64-darwin";
  # ======================== DO NOT CHANGE THIS ========================
  # https://daiderd.com/nix-darwin/manual/index.html#opt-system.stateVersion
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
  # ======================== DO NOT CHANGE THIS ========================
}

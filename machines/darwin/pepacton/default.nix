# Reference: https://daiderd.com/nix-darwin/manual/index.html
{pkgs, config, ...}: {
  users.users.henrikvt = {
    home = "/Users/henrikvt";
    packages = with pkgs; [
      nixd
      wifi-password
      just
      kraft
    ];
  };

  environment.shellAliases = {
    rebuild = "darwin-rebuild switch --flake /Users/henrikvt/Desktop/Code/projects/nixmachines#pepacton";
  };

  networking.hostName = "pepacton";

  nixpkgs.hostPlatform = "aarch64-darwin";
  # ======================== DO NOT CHANGE THIS ========================
  # https://daiderd.com/nix-darwin/manual/index.html#opt-system.stateVersion
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
  # ======================== DO NOT CHANGE THIS ========================
}

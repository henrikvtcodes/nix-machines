{
  pkgs ? import <nixpkgs> { },
  ...
}:
{
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes ca-derivations";
    nativeBuildInputs = with pkgs; [
      nix
      home-manager
      nil
      nixfmt
      git

      ssh-to-age
      age
      ragenix
      deploy-rs
    ];
  };
}

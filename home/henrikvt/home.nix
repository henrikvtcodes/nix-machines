{pkgs, ...}: {
  imports = [
    ./zsh.nix
  ];

  home = {
    username = "henrikvt";
    homeDirectory = "/home/henrikvt";

    packages = with pkgs; [
    ];

    shellAliases = {
      cat = "bat -p";
      less = "bat --style plain --paging always";
    };
  };
}

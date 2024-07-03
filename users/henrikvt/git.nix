{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  programs.git = {
    enable = true;
    userEmail = "commits@henrikvt.com";
    userName = "henrikvtcodes";
    aliases = {
      "pl" = "pull";
      "ps" = "push";
      "st" = "status";
      "co" = "checkout";
      "br" = "branch";
      "ci" = "commit";
      "df" = "diff";
      "lg" = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      "lga" = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all";
      "l" = "log --oneline --decorate";
      "la" = "log --oneline --decorate --all";
      "s" = "status -s";
      "a" = "add";
      "cm" = "commit -m";
    };
  };

  programs.zsh.shellAliases = {
    "gp" = "git push";
    "gl" = "git pull";
    "gcm" = "git commit -m";
    "gco" = "git checkout";
  };
}

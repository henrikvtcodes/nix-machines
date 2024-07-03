{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bat.enable = true;

  programs.btop.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}

# Major credit to Daniel Brendgen-Czerwonk
# https://github.com/czerwonk/nixfiles/blob/main/nixos/services/mastodon/default.nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.svcs.mastodon;
in {
  options.svcs.mastodon = with lib; {
    enable = mkEnableOption "Enable Mastodon";
  };

  config = lib.mkIf cfg.enable (with lib; {
    environment.systemPackages = with pkgs; [mastodon];
  });
}

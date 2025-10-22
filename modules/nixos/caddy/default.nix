{
  config,
  lib,
  ...
}: let
  cfg = config.my.services.caddy;
in
  with lib; {
    options.my.services.caddy = {
      enable = mkEnableOption "Enable Custom Caddy";
    };

    config = mkIf cfg.enable {
      services.caddy = {
        enable = mkDefault true;
        package = pkgs.caddy.withPlugins {
          plugins = ["github.com/caddy-dns/cloudflare@v0.2.1"];
          hash = "sha256-UwrkarDwfb6u+WGwkAq+8c+nbsFt7sVdxVAV9av0DLo=";
        };
      };
    };
  }

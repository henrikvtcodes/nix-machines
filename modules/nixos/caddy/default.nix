{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.services.caddy;

  devModeConfig = lib.concatStringsSep "\n" (
    if cfg.devMode
    then ["https_port 60443" "http_port 60080" "acme_ca https://acme-staging-v02.api.letsencrypt.org/directory"]
    else []
  );
in
  with lib; {
    options.my.services.caddy = {
      enable = mkEnableOption "Enable Custom Caddy";
      devMode = mkEnableOption "Run caddy in Dev Mode";
      verbose = mkEnableOption "Enable verbose debug logs";
    };

    config = mkIf cfg.enable {
      services.caddy = {
        enable = true;
        enableReload = true;
        package = pkgs.caddy.withPlugins {
          plugins = ["github.com/caddy-dns/cloudflare@v0.2.1"];
          hash = "sha256-p9AIi6MSWm0umUB83HPQoU8SyPkX5pMx989zAi8d/74=";
        };
        environmentFile = config.age.secrets.cfDnsApiToken.path;
        logFormat = mkIf cfg.verbose (lib.mkForce "level DEBUG\nformat console");
        globalConfig = ''
          acme_dns cloudflare {env.CF_DNS_API_TOKEN}
          dns cloudflare {env.CF_DNS_API_TOKEN}
          metrics
          ${devModeConfig}
        '';
        extraConfig = ''
          (universal) {
          	encode zstd gzip
          }

          (csp) {
          	header Content-Security-Policy "default-src 'none'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'"
          }

          (security) {
          	header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
          	header X-Content-Type-Options nosniff
          	header X-XSS-Protection "1; mode=block"
          	header X-Frame-Options DENY
          	header Referrer-Policy no-referrer
          	header Permissions-Policy interest-cohort=()
          	header Cross-Origin-Embedder-Policy require-corp
          	header Cross-Origin-Opener-Policy same-origin
          	header Cross-Origin-Resource-Policy same-origin
          }

          (default) {
          	import universal
          	import security
          }
        '';
      };
    };
  }

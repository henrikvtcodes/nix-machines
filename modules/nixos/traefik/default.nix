{
  config,
  lib,
  ...
}: let
  cfg = config.svcs.traefik;
  tailnetRootDomain = "reindeer-porgy.ts.net";
in {
  options.svcs.traefik = with lib; {
    enable = mkEnableOption "Enable Traefik web proxy service";
    enablePodmanDockerProvider = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Allow traefik to proxy services running in podman containers.
      '';
    };
    logLevel = mkOption {
      type = types.str;
      default = "WARN";
      description = ''
        Log level for Traefik.
      '';
    };
    tls = {
      cloudflareDNS01Challenge = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable Cloudflare DNS-01 Challenge for Let's Encrypt.
        '';
      };
      tailscale = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable Tailscale certresolver
        '';
      };
    };
    domains = mkOption {
      type = types.listOf types.attrs;
      default = [
        {
          main = "unicycl.ing";
          sans = ["*.unicycl.ing"];
        }
      ];
      description = ''
        List of domains to serve with Traefik.
      '';
    };
    environmentFiles = mkOption {
      type = types.listOf types.path;
      default = [];
      description = ''
        List of environment files to load before starting Traefik.
      '';
    };
  };

  config = with lib;
    mkIf cfg.enable {
      services.traefik = {
        enable = true;
        environmentFiles = cfg.environmentFiles;
        staticConfigOptions = {
          entrypoints = {
            http.address = ":80";
            https = {
              address = ":443";
              http.tls = {
                certResolver = "lecf";
                domains = cfg.domains;
              };
            };

            metrics.address = ":9180";
          };

          providers.docker = mkIf cfg.enablePodmanDockerProvider {
            endpoint = "unix:///var/run/podman/podman.sock";
            exposedByDefault = false;
          };

          certificatesResolvers = {
            # Let's Encrypt via Cloudflare
            lecf = mkIf cfg.tls.cloudflareDNS01Challenge {
              acme.storage = "${config.services.traefik.dataDir}/acme-lecf.json";
              acme.dnsChallenge = {
                provider = "cloudflare";
                delayBeforeCheck = 10;
                resolvers = ["8.8.8.8:53"];
                # Let's Encrypt uses Google DNS to verify the challenge
              };
            };
            # Tailscale Internal DNS
            tailscale = mkIf cfg.tls.tailscale {
              acme.storage = "${config.services.traefik.dataDir}/acme-tailscale.json";
              tailscale = {};
            };
          };
          api = {
            insecure = true;
            dashboard = true;
          };
          log = {
            level = cfg.logLevel;
            noColor = false;
          };
          metrics.prometheus = {
            entryPoint = "metrics";
            addEntryPointsLabels = true;
            addServicesLabels = true;
            buckets = [
              0.1
              0.3
              1.2
              5.0
            ];
          };
        };
      };
      users.users.traefik.extraGroups = [
        "acme"
        "docker"
        "podman"
      ];
    };
}

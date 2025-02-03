# Major credit to Daniel Brendgen-Czerwonk
# https://github.com/czerwonk/nixfiles/blob/main/nixos/services/mastodon/default.nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.svcs.mastodon;
  version = "4.3.3";
  interfaceDomain = "mstdn.${cfg.rootDomain}";

  env = {
    # General Config
    RAILS_ENV = "production";
    RAILS_LOG_LEVEL = "warn";
    NODE_ENV = "production";
    RAILS_SERVE_STATIC_FILES = "true";
    SINGLE_USER_MODE = "true";
    DEFAULT_LOCALE = "en";
    SKIP_POST_DEPLOYMENT_MIGRATIONS = "false";
    # Serve ui on mstdn.${domain}, but use ${domain} for my handle
    WEB_DOMAIN = interfaceDomain;
    LOCAL_DOMAIN = cfg.rootDomain;

    # Performance/Scaling
    MAX_THREADS = "2";
    SIDEKIQ_CONCURRENCY = "2";

    # Mail
    SMTP_SERVER = "smtp.improvmx.com";
    SMTP_PORT = "587";
    SMTP_LOGIN = "mastodon@${cfg.rootDomain}"; # ImprovMX uses the full email address as the username
    # SMTP_PASSWORD is defined in secret file
    SMTP_FROM_ADDRESS = "mastodon@${cfg.rootDomain}";

    # Postgres Database
    DB_HOST = "mastodon-db";
    DB_PORT = "5432";
    DB_NAME = "postgres";
    DB_USER = "postgres";
    DB_PASS = "";

    # Redis Cache
    REDIS_HOST = "mastodon-redis";
    REDIS_PORT = "6379";
    REDIS_PASSWORD = "";

    # Disable ElasticSearch
    ES_ENABLED = "false";
  };

  secretEnvFiles = [
    cfg.secretKeyBaseEnvFile
    cfg.otpSecretEnvFile
    cfg.vapidKeysEnvFile
    cfg.smtpPasswordEnvFile
    cfg.activeRecordEncryptionEnvFile
  ];
in {
  options.svcs.mastodon = with lib; {
    enable = mkEnableOption "Enable Mastodon";
    configureTraefik = mkEnableOption "Add Traefik Config";
    rootDomain = mkOption {
      type = types.str;
      default = "unicycl.ing";
      description = "Root domain for Mastodon";
    };
    mastodonWebPort = mkOption {
      type = types.int;
      default = 55010;
      description = "Port for Mastodon web interface";
    };
    mastodonStreamPort = mkOption {
      type = types.int;
      default = 55020;
      description = "Port for Mastodon streaming interface";
    };
    secretKeyBaseEnvFile = mkOption {
      type = types.path;
      default = null;
      description = "Path to the secret key base file";
    };
    otpSecretEnvFile = mkOption {
      type = types.path;
      description = "Path to the OTP secret file";
    };
    vapidKeysEnvFile = mkOption {
      type = types.path;
      description = "Path to the VAPID keys file";
    };
    smtpPasswordEnvFile = mkOption {
      type = types.path;
      description = "Name of the SMTP password environment variable";
    };
    activeRecordEncryptionEnvFile = mkOption {
      type = types.path;
      description = "Path to the Active Record encryption environment variables file";
    };
  };

  config = with lib;
    mkIf cfg.enable {
      systemd.services.podman-create-mastodon-stuff = {
        serviceConfig = {
          Group = "podman";
          Type = "oneshot";
          Restart = "on-failure";

          ProtectSystem = "strict";
          ProtectHostname = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;

          ReadWritePaths = [
            "/etc/containers"
            "/var/lib/containers"
          ];

          ExecPaths = ["/nix/store"];
          NoExecPaths = ["/"];
        };
        unitConfig = {StartLimitInterval = 5;};
        wantedBy = [
          # "multi-user.target"
          # "podman-mastodon-web.service"
          "podman-mastodon-db.service"
          "podman-mastodon-redis.service"
          # "podman-mastodon-streaming.service"
          # "podman-mastodon-sidekiq.service"
        ];
        path = [pkgs.podman];
        preStart = "/usr/bin/env sleep 4";
        script = ''
          echo "Creating Mastodon network"
          podman network exists mastodon || podman network create mastodon

          echo "Creating Mastodon volumes"
          podman volume exists mastodon_pgdata || podman volume create mastodon_pgdata
          podman volume exists mastodon_redisdata || podman volume create mastodon_redisdata
          podman volume exists mastodon_sysdata || podman volume create mastodon_sysdata

          echo "Init complete"
        '';
      };

      virtualisation.oci-containers.containers = {
        mastodon-db = {
          image = "postgres:14-alpine";

          autoStart = true;
          extraOptions = [
            "--network=mastodon"
            "--shm-size=268435456"
          ];

          environment = {
            POSTGRES_HOST_AUTH_METHOD = "trust";
          };

          volumes = [
            "mastodon_pgdata:/var/lib/postgresql/data"
          ];
        };

        mastodon-redis = {
          image = "redis:7-alpine";

          autoStart = true;
          extraOptions = [
            "--network=mastodon"
          ];

          volumes = [
            "mastodon_redisdata:/data"
          ];
        };

        mastodon-prepare = {
          image = "ghcr.io/glitch-soc/mastodon:v${version}";
          cmd = ["bundle" "exec" "rails" "db:migrate" "&&" "bundle" "exec" "rails" "assets:precompile"];

          autoStart = true;
          extraOptions = [
            "--runtime=${pkgs.gvisor}/bin/runsc"
            "--network=mastodon"
            "--restart=on-failure"
            "--detach=false"
          ];

          environment = env;
          environmentFiles = secretEnvFiles;

          volumes = [
            "mastodon_sysdata:/opt/mastodon/public/system"
          ];

          dependsOn = [
            "mastodon-db"
          ];
        };

        mastodon-web = {
          image = "ghcr.io/glitch-soc/mastodon:v${version}";
          cmd = ["bundle" "exec" "puma" "-C" "config/puma.rb"];

          autoStart = true;
          extraOptions = [
            "--runtime=${pkgs.gvisor}/bin/runsc"
            "--network=mastodon"
          ];

          environment = env;
          environmentFiles = secretEnvFiles;

          volumes = [
            "mastodon_sysdata:/opt/mastodon/public/system"
          ];

          dependsOn = [
            "mastodon-db"
            "mastodon-redis"
            "mastodon-migrate"
          ];

          ports = [
            "127.0.0.1:${toString cfg.mastodonWebPort}:3000"
          ];
        };

        mastodon-streaming = {
          image = "ghcr.io/glitch-soc/mastodon-streaming:v${version}";
          cmd = ["node" "./streaming/index.js"];

          autoStart = true;
          extraOptions = [
            "--runtime=${pkgs.gvisor}/bin/runsc"
            "--network=mastodon"
          ];

          environment = env;
          environmentFiles = secretEnvFiles;

          ports = [
            "127.0.0.1:${toString cfg.mastodonStreamPort}:4000"
          ];

          dependsOn = [
            "mastodon-db"
            "mastodon-redis"
            "mastodon-migrate"
          ];
        };

        mastodon-sidekiq = {
          image = "ghcr.io/glitch-soc/mastodon:v${version}";
          cmd = ["bundle" "exec" "sidekiq" "-c" "${env.SIDEKIQ_CONCURRENCY}"];

          autoStart = true;
          extraOptions = [
            "--network=mastodon"
            "--cap-add=NET_BIND_SERVICE"
          ];

          environment = env;
          environmentFiles = secretEnvFiles;

          volumes = [
            "mastodon_sysdata:/opt/mastodon/public/system"
          ];

          dependsOn = [
            "mastodon-db"
            "mastodon-redis"
            "mastodon-migrate"
          ];
        };
      };

      systemd.services.podman-mastodon-migrate = {
        serviceConfig = {
          Restart = mkForce "on-failure";
        };
      };

      environment.shellAliases = {mastodon = "podman exec mastodon-web";};

      services.traefik.dynamicConfigOptions = lib.mkIf cfg.configureTraefik {
        http = {
          routers = {
            mastodon = {
              rule = "Host(`${interfaceDomain}`)";
              service = "mastodon";
              entryPoints = [
                "https"
                "http"
              ];
            };
          };
          services = {
            mastodon = {
              loadBalancer = {
                servers = [{url = "http://127.0.0.1:${toString cfg.mastodonWebPort}";}];
              };
            };
          };
        };
      };
    };
}

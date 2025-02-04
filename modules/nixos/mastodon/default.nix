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
    RAILS_LOG_LEVEL = "debug";
    NODE_ENV = "production";
    RAILS_SERVE_STATIC_FILES = "true";
    SINGLE_USER_MODE = "true";
    DEFAULT_LOCALE = "en";
    SKIP_POST_DEPLOYMENT_MIGRATIONS = "false";
    # Serve ui on mstdn.${domain}, but use ${domain} for my handle
    WEB_DOMAIN = interfaceDomain;
    LOCAL_DOMAIN = cfg.rootDomain;

    # Performance/Scaling
    MAX_THREADS = "5"; # Read: Puma Threads
    WEB_CONCURRENCY = "1"; # Read: Puma Processes
    SIDEKIQ_CONCURRENCY = "1"; # Read: Sidekiq Processes
    SIDEKIQ_THREADS = "15"; # This gets passed as a cli arg, but is here for consistency

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

    # ElasticSearch
    ES_ENABLED = "true";
    ES_HOST = "mastodon-es";
    ES_PORT = "9200";
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
          "podman-mastodon-web.service"
          "podman-mastodon-db.service"
          "podman-mastodon-redis.service"
          "podman-mastodon-streaming.service"
          "podman-mastodon-sidekiq.service"
          "podman-mastodon-prepare.service"
          "podman-mastodon-es.service"
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
          podman volume exists mastodon_searchdata || podman volume create mastodon_searchdata

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

        mastodon-es = {
          image = "docker.elastic.co/elasticsearch/elasticsearch:8.16.1";

          autoStart = true;
          extraOptions = [
            "--network=mastodon"
            "--ulimit=memlock=-1:-1"
            "--ulimit=nofile=65536:65536"
          ];

          environment = {
            ES_JAVA_OPTS = "-Xms512m -Xmx512m -Des.enforce.bootstrap.checks=true";
            "xpack.license.self_generated.type" = "basic";
            "xpack.security.enabled" = "false";
            "xpack.watcher.enabled" = "false";
            "xpack.graph.enabled" = "false";
            "xpack.ml.enabled" = "false";
            "bootstrap.memory_lock" = "true";
            "cluster.name" = "es-mastodon";
            "discovery.type" = "single-node";
            "thread_pool.write.queue_size" = "1000";
          };

          volumes = [
            "mastodon_searchdata:/usr/share/elasticsearch/data"
          ];
        };

        mastodon-prepare = {
          image = "ghcr.io/glitch-soc/mastodon:v${version}";
          cmd = ["bundle" "exec" "rails" "db:migrate"];
          # cmd = ["bundle" "exec" "rails" "db:migrate"];

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
          cmd = ["bundle" "exec" "rails" "assets:precompile" "&&" "bundle" "exec" "puma" "-C" "config/puma.rb"];

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
            "mastodon-prepare"
            "mastodon-es"
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
            "mastodon-prepare"
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
            "mastodon-prepare"
          ];
        };
      };

      systemd.services.podman-mastodon-prepare = {
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

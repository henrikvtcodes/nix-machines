{
  config,
  lib,
  pkgs,
  ...
}: let
  mastoProxyPort = 55080;
  mastoHttpPort = 55443;
  mastoInternalDomain = "mastodon.localhost";
  # mastoStreamPort = 55444;
  domain = "unicycl.ing";
  interfaceDomain = "mstdn.${domain}";
in {
  services.mastodon = {
    enable = true;
    # enableUnixSocket = false;
    webPort = mastoHttpPort;
    localDomain = domain;
    extraConfig = {
      WEB_DOMAIN = interfaceDomain;
      SINGLE_USER_MODE = "true";
      DEFAULT_LOCALE = "en";
      RAILS_LOG_LEVEL = "debug";
      # RAILS_SERVE_STATIC_FILES = "true";
    };
    configureNginx = false;
    streamingProcesses = 1;
    # streamingPort = mastoStreamPort;

    # Connect to Postgres DB via Unix Sockets using Peer Authentication, all settings are default
    database = {
      # host = "localhost";
      # port = 5432;
      createLocally = true;
    };

    smtp = {
      host = "smtp.improvmx.com";
      port = 587;
      user = "mastodon@${domain}";
      passwordFile = config.age.secrets.mastodonSmtpPassword;
      createLocally = false;
      fromAddress = "mastodon@${domain}";
    };
  };

  # External Reverse Proxy
  services.traefik.dynamicConfigOptions = {
    http = {
      routers = {
        mastodon = {
          rule = "Host(`${interfaceDomain}`)";
          service = "mastodon";
          entryPoints = [
            "https"
            "http"
          ];
          tls.certResolver = "lecf";
        };
      };
      services = {
        mastodon = {
          loadBalancer = {
            # servers = [{url = "http://unix:/run/mastodon-web/web.socket";}];
            servers = [{url = "http://localhost:${toString mastoProxyPort}";}];
          };
        };
      };
    };
  };

  # Internal Proxy
  services.caddy = {
    enable = true;
    extraConfig = ''
      :${toString mastoProxyPort} {
        handle_path /system/* {
            file_server * {
                root /var/lib/mastodon/public-system
            }
        }

        handle /api/v1/streaming/* {
            reverse_proxy  unix//run/mastodon-streaming/streaming-1.socket
        }

        route * {
            file_server * {
            root ${config.services.mastodon.package}/public
            pass_thru
            }
            reverse_proxy * unix//run/mastodon-web/web.socket
        }

        handle_errors {
            root * ${config.services.mastodon.package}/public
            rewrite 500.html
            file_server
        }

        encode gzip

        header /* {
            Strict-Transport-Security "max-age=31536000;"
        }

        header /emoji/* Cache-Control "public, max-age=31536000, immutable"
        header /packs/* Cache-Control "public, max-age=31536000, immutable"
        header /system/accounts/avatars/* Cache-Control "public, max-age=31536000, immutable"
        header /system/media_attachments/files/* Cache-Control "public, max-age=31536000, immutable"
      }
    '';
  };

  users.users.mastodon.extraGroups = ["nginx"];
  users.users.caddy.extraGroups = ["mastodon"];
  systemd.services.caddy = {
    wants = ["mastodon.target"];
    serviceConfig.ReadWriteDirectories = lib.mkForce ["/var/lib/caddy" "/run/mastodon-web"];
  };
  # systemd.tmpfiles.rules = [
  #   "d! /run/mastodon-web 0755 - nginx -"
  #   "z /run/mastodon-web - - nginx -"
  # ];

  # Postgres
  services.postgresql = {
    enable = true;
    # enableTCPIP = true;
    enableJIT = true;
    ensureDatabases = ["mastodon"];
    ensureUsers = [
      {
        name = "mastodon";
        ensureDBOwnership = true;
      }
    ];
  };
}

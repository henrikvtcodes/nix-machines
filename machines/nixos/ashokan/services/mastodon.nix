{
  config,
  lib,
  pkgs,
  ...
}: let
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
            servers = [{url = "http://localhost:${toString mastoHttpPort}";}];
          };
        };
      };
    };
  };

  # Internal Proxy
  services.nginx = {
    enable = true;
    package = pkgs.nginxQuic;
    recommendedProxySettings = false;
    logError = "stderr info";
    proxyCachePath."" = {
      enable = true;
      levels = "1:2";
      keysZoneName = "CACHE";
      keysZoneSize = "10m";
      maxSize = "1g";
      inactive = "7d";
    };
    virtualHosts.${interfaceDomain} = {
      # serverName = "localhost";
      listen = [
        {
          addr = "0.0.0.0";
          port = mastoHttpPort;
          ssl = false;
        }
        {
          addr = "[::]";
          port = mastoHttpPort;
          ssl = false;
        }
      ];

      root = "${config.services.mastodon.package}/public";

      locations = {
        "/" = {
          tryFiles = "$uri @proxy";
        };

        "/system/".alias = "/var/lib/mastodon/public-system/";

        # "~ ^/assets/" = {
        #   extraConfig = ''
        #     add_header Cache-Control "public, max-age=2419200, must-revalidate";
        #     add_header Strict-Transport-Security "max-age=63072000; includeSubDomains";
        #   '';
        #   tryFiles = "$uri =404";
        # };

        # "~ ^/avatars/" = {
        #   extraConfig = ''
        #     add_header Cache-Control "public, max-age=2419200, must-revalidate";
        #     add_header Strict-Transport-Security "max-age=63072000; includeSubDomains";
        #   '';
        #   tryFiles = "$uri =404";
        # };

        # "~ ^/emoji/" = {
        #   extraConfig = ''
        #     add_header Cache-Control "public, max-age=2419200, must-revalidate";
        #     add_header Strict-Transport-Security "max-age=63072000; includeSubDomains";
        #   '';
        #   tryFiles = "$uri =404";
        # };

        # "~ ^/system/" = {
        #   extraConfig = ''
        #     add_header Cache-Control "public, max-age=2419200, immutable";
        #     add_header Strict-Transport-Security "max-age=63072000; includeSubDomains";
        #     add_header X-Content-Type-Options nosniff;
        #     add_header Content-Security-Policy "default-src 'none'; form-action 'none'";
        #   '';
        #   tryFiles = "$uri =404";
        # };

        "^~ /api/v1/streaming" = {
          proxyPass = "http://unix:/run/mastodon-streaming/streaming-1.socket";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_buffering off;
            tcp_nodelay on;
            add_header Strict-Transport-Security "max-age=63072000; includeSubDomains";
          '';
        };

        "@proxy" = {
          proxyPass = "http://unix:/run/mastodon-web/web.socket";
          proxyWebsockets = true;
          extraConfig = ''
            # proxy_cache CACHE;
            # proxy_cache_valid 200 7d;
            # proxy_cache_valid 410 24h;
            # proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
            # add_header X-Cached $upstream_cache_status;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };

      # extraConfig = ''
      #   error_page 404 500 501 502 503 504 /500.html;
      #   gzip on;
      #   gzip_disable "msie6";
      #   gzip_vary on;
      #   gzip_proxied any;
      #   gzip_comp_level 6;
      #   gzip_buffers 16 8k;
      #   gzip_http_version 1.1;
      #   gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript image/svg+xml image/x-icon;
      # '';
    };
  };

  users.users.mastodon.extraGroups = ["nginx"];
  users.users.nginx.extraGroups = ["mastodon"];
  systemd.services.nginx = {
    wants = ["mastodon.target"];
    # serviceConfig.ReadWriteDirectories = lib.mkForce ["/run/mastodon-web"];
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

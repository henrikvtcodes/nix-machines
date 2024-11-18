{config, ...}: let
  mastoHttpPort = 55443;
  mastoStreamPort = 55444;
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
      RAILS_SERVE_STATIC_FILES = "true";
    };
    configureNginx = false;
    streamingProcesses = 1;
    # streamingPort = mastoStreamPort;

    # Connect to Postgres DB via Unix Sockets using Peer Authentication, all settings are default
    database = {
      host = "/run/postgresql";
      createLocally = false;
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

  # Reverse Proxy
  services.traefik.dynamicConfigOptions = {
    http = {
      routers = {
        masto-web = {
          rule = "Host(`${interfaceDomain}`)";
          service = "masto-web";
          entryPoints = [
            "https"
            "http"
          ];
          tls.certResolver = "lecf";
        };
        masto-stream = {
          rule = "Host(`${interfaceDomain}`) && PathPrefix(`/api/v1/streaming`)";
          service = "masto-stream";
          entryPoints = [
            "https"
            "http"
          ];
          priority = 1;
          tls.certResolver = "lecf";
        };
      };
      services = {
        masto-web = {
          loadBalancer = {
            servers = [{url = "unix:///run/mastodon-web/web.socket";}];
            # servers = [{url = "http://localhost:${toString mastoHttpPort}";}];
          };
        };
        masto-stream = {
          loadBalancer = {
            servers = [{url = "unix:///run/mastodon-streaming/streaming-1.socket";}];
          };
        };
      };
    };
  };

  # Postgres
  services.postgresql = {
    enable = true;
    ensureDatabases = ["mastodon"];
    ensureUsers = [
      {
        name = "mastodon";
        ensureDBOwnership = true;
      }
    ];
  };
}

{
  config,
  lib,
  ...
}: {
  services.authentik = {
    enable = true;
    environmentFile = config.age.secrets.authentikEnvVars.path;
    createDatabase = true;
    settings = {
      email = {
        host = "smtp.improvmx.com";
        port = 587;
        username = "auth-noreply@unicycl.ing";
        use_tls = true;
        use_ssl = false;
        from = "auth-noreply@unicycl.ing";
      };
      storage.media = {
        backend = "file";
      };
      disable_startup_analytics = true;
    };
  };

  users = {
    users.authentik = {
      isSystemUser = true;
      createHome = true;
      home = "/var/lib/authentik";
      group = "authentik";
    };
    groups.authentik = {};
  };

  systemd.services = with lib; {
    authentik-migrate = {
      after = ["redis-authentik.service" "postgresql.service"];
      before = mkForce ["authentik.service"];
      serviceConfig.User = "authentik";
      serviceConfig.Group = "authentik";
    };

    authentik = {
      after = ["authentik-migrate.service"];
      serviceConfig.User = "authentik";
      serviceConfig.Group = "authentik";
    };

    authentik-worker = {
      serviceConfig.User = "authentik";
      serviceConfig.Group = "authentik";
    };
  };

  users.users.caddy.extraGroups = ["authentik"];

  services.caddy.virtualHosts."idp.unicycl.ing" = {
    extraConfig = ''
      handle /media/public* {
          root * ${config.users.users.authentik.home}/media/public
          file_server
      }
      handle /dist* {
        root * ${config.users.users.authentik.home}/web/dist
        file_server
      }
      handle {
        reverse_proxy http://localhost:9000
      }
    '';
  };

}

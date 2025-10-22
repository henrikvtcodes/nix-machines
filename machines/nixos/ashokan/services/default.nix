{config, ...}: {
  imports = [
    ./metrics.nix
    ./stirling.nix
    ./netbox.nix
    ./mealie.nix
    ./netbird.nix
    ./librenms.nix
    ./smokeping2.nix
  ];

  my.services.smokeping = {
    enable = true;
    domain = "sp.ash.unicycl.ing";
  };

  my.services.traefik = {
    enable = true;
    environmentFiles = [config.age.secrets.cfDnsApiToken.path];
  };

  my.services.caddy = {
    enable = true;
    devMode = true;
  };

  my.services.mastodon = {
    enable = true;
    configureTraefik = true;
    configureCaddy = true;

    secretKeyBaseEnvFile = config.age.secrets.mastodonSecretKeyBase.path;
    otpSecretEnvFile = config.age.secrets.mastodonOtpSecret.path;
    vapidKeysEnvFile = config.age.secrets.mastodonVapidKeys.path;
    smtpPasswordEnvFile = config.age.secrets.mastodonSmtpPassword.path;
    activeRecordEncryptionEnvFile = config.age.secrets.mastodonAREncryptionEnvVars.path;
    s3SecretKeysEnvFile = config.age.secrets.mastodonJortageSecretEnvVars.path;
  };

  my.services.copyparty = {
    enable = true;
  };

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
        backend = "s3";
      };
      disable_startup_analytics = true;
      avatars = "initials";
    };
  };

  services.caddy.virtualHosts."idp.unicycl.ing" = {
    extraConfig = ''
      reverse_proxy https://localhost:9443
    '';
  };

  services.traefik.dynamicConfigOptions = let
    domain = "idp.unicycl.ing";
  in {
    http = {
      routers = {
        authentik = {
          rule = "Host(`${domain}`)";
          service = "authentik";
          entryPoints = [
            "https"
            "http"
          ];
        };
      };
      services = {
        authentik = {
          loadBalancer = {
            servers = [{url = "https://localhost:9443";}];
          };
        };
      };
    };
  };
}

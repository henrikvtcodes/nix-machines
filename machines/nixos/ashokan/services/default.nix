{config, ...}: {
  imports = [
    ./metrics.nix
  ];

  my.services.traefik = {
    enable = true;
    environmentFiles = [config.age.secrets.cfDnsApiToken.path];
  };

  my.services.mastodon = {
    enable = true;
    configureTraefik = true;

    secretKeyBaseEnvFile = config.age.secrets.mastodonSecretKeyBase.path;
    otpSecretEnvFile = config.age.secrets.mastodonOtpSecret.path;
    vapidKeysEnvFile = config.age.secrets.mastodonVapidKeys.path;
    smtpPasswordEnvFile = config.age.secrets.mastodonSmtpPassword.path;
    activeRecordEncryptionEnvFile = config.age.secrets.mastodonAREncryptionEnvVars.path;
    s3SecretKeysEnvFile = config.age.secrets.mastodonJortageSecretEnvVars.path;
  };

  services.stirling-pdf = {
    enable = true;
    environment = {
      SECURITY_ENABLECSRF = "true";
      SERVER_HOST = "0.0.0.0";
      SERVER_PORT = "18180";
    };
  };

  services.traefik.dynamicConfigOptions = {
    http = {
      routers = {
        stirling-pdf = {
          rule = "Host(`pdf.unicycl.ing`)";
          service = "stirling-pdf";
          entryPoints = [
            "https"
            "http"
          ];
        };
      };
      services = {
        stirling-pdf = {
          loadBalancer = {
            servers = [{url = "http://localhost:${config.services.stirling-pdf.environment.SERVER_PORT}";}];
          };
        };
      };
    };
  };
}

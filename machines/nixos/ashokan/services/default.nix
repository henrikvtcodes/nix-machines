{config, ...}: {
  imports = [
    ./metrics.nix
    ./stirling.nix
    ./netbox.nix
    ./mealie.nix
    ./netbird.nix
    ./librenms.nix
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

  my.services.copyparty = {
    enable = true;
  };
}

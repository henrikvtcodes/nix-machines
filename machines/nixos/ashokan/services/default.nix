{config, ...}: {
  imports = [];

  svcs.traefik = {
    enable = true;
    environmentFiles = [config.age.secrets.cfDnsApiToken.path];
  };

  svcs.mastodon = {
    enable = true;
    configureTraefik = true;
    secretKeyBaseEnvFile = config.age.secrets.mastodonSecretKeyBase.path;
    otpSecretEnvFile = config.age.secrets.mastodonOtpSecret.path;
    vapidKeysEnvFile = config.age.secrets.mastodonVapidKeys.path;
    smtpPasswordEnvFile = config.age.secrets.mastodonSmtpPassword.path;
    activeRecordEncryptionEnvFile = config.age.secrets.mastodonAREncryptionEnvVars.path;
  };
}

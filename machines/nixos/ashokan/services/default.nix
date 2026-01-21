{
  config,
  lib,
  ...
}: {
  imports = [
    ./metrics.nix
    ./stirling.nix
    ./netbox.nix
    ./mealie.nix
    ./netbird.nix
    ./librenms.nix
    # ./smokeping2.nix
    ./authentik.nix
    ./zipline.nix
  ];

  # my.services.smokeping = {
  #   enable = true;
  #   domain = "sp.ash.unicycl.ing";
  # };

  my.services.caddy = {
    enable = true;
    devMode = false;
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

  services.nginx.enable = lib.mkForce false;
}

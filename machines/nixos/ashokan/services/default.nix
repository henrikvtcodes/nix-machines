{config, ...}: {
  imports = [./mastodon.nix];

  svcs.traefik = {
    enable = true;
    environmentFiles = [config.age.secrets.cfDnsApiToken.path];
  };
}

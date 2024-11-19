{config, ...}: {
  imports = [];

  svcs.traefik = {
    enable = true;
    environmentFiles = [config.age.secrets.cfDnsApiToken.path];
  };
}

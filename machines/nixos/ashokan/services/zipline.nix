{
  pkgs,
  config,
  ...
}: let
  port = 26007;
in {
  services.zipline = {
    enable = true;
    settings = {
      CORE_PORT = port;
      DATASOURCE_TYPE = "s3";
      DATASOURCE_S3_FORCE_PATH_STYLE = "false";
    };
    environmentFiles = [config.age.secrets.ziplineEnvVars.path];
  };

  services.caddy.virtualHosts."share.unicycl.ing" = {
    extraConfig = ''
      reverse_proxy http://localhost:${toString port}
    '';
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.svcs.auth.kratos;
in
{
  options.svcs.auth.kratos = with lib; {
    enable = mkEnableOption { description = "Enable Ory Kratos Identity Server"; };
    domainName = mkOption {
      type = types.str;
      description = "Domain name for Kratos";
    };
    publicApiPort = mkOption {
      type = types.int;
      default = 4433;
      description = "Port for Kratos public API";
    };
    adminApiPort = mkOption {
      type = types.int;
      default = 4434;
      description = "Port for Kratos admin API";
    };
  };

  config = lib.mkIf cfg.enable {
    svcs.auth.enable = lib.mkForce true;

    virtualisation.oci-containers.containers = {
      kratos = {
        autoStart = true;
        image = "oryd/kratos:v1.2.0";
        ports = [
          
          "${cfg.publicApiPort}:4433"
          "${cfg.adminApiPort}:4434"
        ];
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.kratos.rule" = "Host(`${cfg.domainName}`)";
          "traefik.http.routers.kratos.entrypoints" = "http,https";
          "traefik.http.routers.kratos.tls" = "true";
          "traefik.http.routers.kratos.tls.certresolver" = "lecf";
          "traefik.http.routers.kratos.service" = "kratos";

          "traefik.http.services.kratos.loadbalancer.server.port" = "${cfg.publicApiPort}";
        };
        volumes = [ "/var/lib/auth/kratos:/var/lib/auth/kratos" ];

        extraOptions = [ "--pull=newer" ];
      };
    };
  };
}

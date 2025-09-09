{
  config,
  lib,
  ...
}: let
  cfg = config.my.services.pocketid;
in {
  options.my.services.pocketid = with lib; {
    enable = mkEnableOption {description = "Enable PocketID";};
    domainName = mkOption {
      type = types.str;
      description = "Domain name for PocketID";
    };
    port = mkOption {
      type = types.int;
      default = 7007;
      description = "Port for PocketID";
    };
    serviceHttpPort = mkOption {
      type = types.int;
      default = 7007;
      description = "Port for PocketID public API";
    };
    frontendApiPort = mkOption {
      type = types.int;
      default = 7070;
      description = "Port for PocketID public API";
    };
    adminApiPort = mkOption {
      type = types.int;
      default = 7777;
      description = "Port for PocketID admin API";
    };
    dataPath = mkOption {
      type = types.str;
      default = "/var/lib/pocketid";
      description = "Path to store PocketID data";
    };
    traefikProxy = mkEnableOption {description = "Enable Traefik proxy for PocketID";};
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataPath} 0764 root podman -"
      "d ${cfg.dataPath}/uploads 0764 root podman -"
      "z ${cfg.dataPath}/pocket-id.db 0764 root podman -"
    ];

    virtualisation.oci-containers.containers.pocketid = {
      image = "ghcr.io/pocket-id/pocket-id:v1.9";
      ports = [
        "${toString cfg.frontendApiPort}:${toString cfg.frontendApiPort}"
        "${toString cfg.adminApiPort}:${toString cfg.adminApiPort}"
        # Map the caddy internal port (80) to serviceHttpPort externally
        "${toString cfg.serviceHttpPort}:80"
      ];
      volumes = [
        "${cfg.dataPath}:/app/backend/data"
        # "${cfg.dataPath}/uploads:/app/uploads"
      ];
      environment = {
        APP_URL = "https://${cfg.domainName}";
        TRUST_PROXY = "true";
        DB_CONNECTION_STRING = "file:/app/backend/data/pocket-id.db";
        UPLOAD_PATH = "/app/backend/data/uploads";
        PORT = toString cfg.port;
        BACKEND_PORT = toString cfg.adminApiPort;
      };
    };

    services.traefik.dynamicConfigOptions = lib.mkIf cfg.traefikProxy {
      http = {
        routers = {
          pocketid = {
            rule = "Host(`${cfg.domainName}`)";
            service = "pocketid";
            entryPoints = [
              "https"
              "http"
            ];
          };
        };
        services = {
          pocketid = {
            loadBalancer = {
              servers = [{url = "http://localhost:${toString cfg.port}";}];
            };
          };
        };
      };
    };
  };
}

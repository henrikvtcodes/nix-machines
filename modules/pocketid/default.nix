{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.svcs.pocketid;
in
{

  options.svcs.pocketid = with lib; {
    enable = mkEnableOption { description = "Enable PocketID"; };
    domainName = mkOption {
      type = types.str;
      description = "Domain name for PocketID";
    };
    frontendApiPort = mkOption {
      type = types.int;
      default = 3000;
      description = "Port for PocketID public API";
    };
    adminApiPort = mkOption {
      type = types.int;
      default = 3030;
      description = "Port for PocketID admin API";
    };
    dataPath = mkOption {
      type = types.str;
      default = "/var/lib/pocketid";
      description = "Path to store PocketID data";
    };
    traefikProxy = mkEnableOption {
      description = "Enable Traefik proxy for PocketID";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataPath} 0755 root podman -"
      "d ${cfg.dataPath}/uploads 0755 root podman -"
      "z ${cfg.dataPath}/pocket-id.db 0644 root podman -"
    ];

    virtualisation.oci-containers.containers.pocketid = {
      image = "stonith404/pocket-id:latest";
      ports = [ "${toString cfg.frontendApiPort}:${toString cfg.frontendApiPort}" ];
      volumes = [
        "${cfg.dataPath}/data:/app/data"
        "${cfg.dataPath}/uploads:/app/uploads"
      ];
      environment = {
        PUBLIC_APP_URL = "https://${cfg.domainName}";
        TRUST_PROXY = "true";
        DB_PATH = "${cfg.dataPath}/pocket-id.db";
        UPLOAD_PATH = "${cfg.dataPath}/uploads";
        INTERNAL_BACKEND_URL = "http://localhost:${toString cfg.adminApiPort}";
        PORT = toString cfg.frontendApiPort;
        BACKEND_PORT = toString cfg.adminApiPort;
      };
    };

    services.traefik.dynamicConfigOptions = lib.mkIf cfg.traefikProxy {
      http = {
        routers.pocketid = {
          rule = "Host(`${cfg.domainName}`)";
          service = "pocketid";
          entryPoints = [
            "https"
            "http"
          ];
          tls.certResolver = "lecf";
        };
        services.woodpecker = {
          loadBalancer = {
            servers = [ { url = "http://localhost:${toString cfg.frontendApiPort}"; } ];
          };
        };
      };
    };
  };
}

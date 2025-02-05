{
  config,
  lib,
  ...
}: let
  cfg = config.my.services.ci-server;
in {
  options.my.services.ci-server = {
    enable = lib.mkEnableOption "ci-server";
    httpPort = lib.mkOption {
      type = lib.types.int;
      default = 3007;
      description = "Port to listen on";
    };
    grpcPort = lib.mkOption {
      type = lib.types.int;
      default = 3006;
      description = "Port to listen on";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      description = "Domain to listen on";
    };
    environmentFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [];
      description = "Files containing secrets necessary for the server";
    };
    # environmentVars = lib.mkOption {
    #   type = lib.types.attrsOf lib.types.str;
    #   default = { };
    #   description = "Environment variables to set";
    # };
    enableTraefik = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable traefik configuration";
    };
    adminUser = lib.mkOption {
      type = lib.types.str;
      default = "henrikvtcodes";
      description = "Admin user";
    };
    allowedOrgs = lib.mkOption {
      type = lib.types.str;
      default = "orangeunilabs";
      description = "Allowed organizations";
    };
    allowSignup = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Allow signup";
    };
  };

  config = lib.mkIf cfg.enable {
    services.woodpecker-server = {
      enable = true;
      environment = {
        WOODPECKER_HOST = "https://${cfg.domain}";
        WOODPECKER_SERVER_ADDR = ":${toString cfg.httpPort}";
        WOODPECKER_GRPC_ADDR = "0.0.0.0:${toString cfg.grpcPort}";
        WOODPECKER_OPEN = toString cfg.allowSignup;
        WOODPECKER_ADMIN = cfg.adminUser;
        WOODPECKER_ORGS = cfg.allowedOrgs;
        WOODPECKER_METRICS_SERVER_ADDR = ":3008";
      };
      environmentFile = cfg.environmentFiles;
    };

    services.traefik.dynamicConfigOptions = {
      http = {
        routers.woodpecker = {
          rule = "Host(`${cfg.domain}`)";
          service = "woodpecker";
          entryPoints = [
            "https"
            "http"
          ];
          tls.certResolver = "lecf";
        };
        services.woodpecker = {
          loadBalancer = {
            servers = [{url = "http://localhost:${toString cfg.httpPort}";}];
          };
        };
      };
    };
  };
}

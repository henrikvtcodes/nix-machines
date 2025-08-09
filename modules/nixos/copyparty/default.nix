{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}: let
  cfg = config.my.services.copyparty;
in {
  options.my.services.copyparty = with lib; {
    enable = mkEnableOption "Enable Copyparty, a fast file server";
    port = mkOption {
      type = types.int;
      default = 19190;
      description = "The port copyparty is listening on";
    };
    domain = mkOption {
      type = types.string;
      default = "cp.${networking.hostName}.unicycl.ing";
      description = "The domain copyparty is hosted on";
    };
    enableTraefik = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    imports = [inputs.copyparty.nixosModules.default];

    services.copyparty = {
      enable = true;
      package = inputs.copyparty.packages.${system}.copyparty;
      settings = {
        i = "0.0.0.0";
        # use lists to set multiple values
        p = [cfg.port];
      };
    };

    services.traefik.dynamicConfigOptions = cfg.enableTraefik {
      http = {
        routers.copyparty = {
          rule = "Host(`${cfg.domain}`)";
          service = "copyparty";
          entryPoints = [
            "https"
            "http"
          ];
          tls.certResolver = "lecf";
        };
        services.copyparty = {
          loadBalancer = {
            servers = [{url = "http://localhost:${toString cfg.port}";}];
          };
        };
      };
    };
  };
}

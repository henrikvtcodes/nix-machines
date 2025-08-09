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
  imports = [inputs.copyparty.nixosModules.default];

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
    services.copyparty = {
      enable = true;
      package = inputs.copyparty.packages.${system}.copyparty;
      settings = {
        i = "0.0.0.0";
        # use lists to set multiple values
        p = [cfg.port];

        "/" = {
          # share the contents of "/srv/copyparty"
          path = "/srv/copyparty";
          # see `copyparty --help-accounts` for available options
          access = {
            # everyone gets read-access, but
            r = "*";
            # users "ed" and "k" get read-write
            # rw = ["ed" "k"];
          };
          # see `copyparty --help-flags` for available options
          # flags = {
          #   # "fk" enables filekeys (necessary for upget permission) (4 chars long)
          #   fk = 4;
          #   # scan for new files every 60sec
          #   scan = 60;
          #   # volflag "e2d" enables the uploads database
          #   e2d = true;
          #   # "d2t" disables multimedia parsers (in case the uploads are malicious)
          #   d2t = true;
          #   # skips hashing file contents if path matches *.iso
          #   nohash = "\.iso$";
          # };
        };
      };
    };

    environment.systemPackages = [config.services.copyparty.package];

    services.traefik.dynamicConfigOptions = lib.mkIf cfg.enableTraefik {
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

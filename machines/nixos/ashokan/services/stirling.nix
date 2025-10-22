{config, ...}: {
  services.stirling-pdf = {
    enable = true;
    environment = {
      SECURITY_ENABLECSRF = "true";
      SERVER_HOST = "0.0.0.0";
      SERVER_PORT = "18180";
    };
  };

  services.traefik.dynamicConfigOptions = {
    http = {
      routers = {
        stirling-pdf = {
          rule = "Host(`pdf.unicycl.ing`)";
          service = "stirling-pdf";
          entryPoints = [
            "https"
            "http"
          ];
        };
      };
      services = {
        stirling-pdf = {
          loadBalancer = {
            servers = [{url = "http://localhost:${config.services.stirling-pdf.environment.SERVER_PORT}";}];
          };
        };
      };
    };
  };

  services.caddy.virtualHosts."pdf.unicycl.ing" = {
    extraConfig = ''
      reverse_proxy localhost:${config.services.stirling-pdf.environment.SERVER_PORT}
    '';
  };
}

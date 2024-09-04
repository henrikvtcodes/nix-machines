{ ... }:
{
  services.grafana = {
    enable = true;
    settings = {
      users = {
        editors_can_admin = false;
        viewers_can_edit = false;
        allow_sign_up = false;
      };
      server.http_addr = "0.0.0.0";
      server.domain = "metrics.unicycl.ing";
      server.enable_gzip = true;
    };
    provision.datasources.path = ./datasources.yml;
  };

  services.traefik.dynamicConfigOptions = {
    http = {
      routers.grafana = {
        rule = "Host(`metrics.unicycl.ing`)";
        service = "grafana";
        entryPoints = [
          "https"
          "http"
        ];
      };
      services.grafana = {
        loadBalancer = {
          servers = [ { url = "http://localhost:3000"; } ];
        };
      };
    };
  };
}

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
    };
    provision.datasources.path = ./datasources.yml;
  };

  services.traefik.dynamicConfigOptions = {
    http = {
      routers.grafana = {
        rule = "Host(`metrics.unicycl.ing`)";
        service = "grafana";
        entryPoints = [ "https" ];
      };
      services.grafana = {
        loadBalancer = {
          servers = [ { url = "http://localhost:3000"; } ];
        };
      };
    };
  };
}

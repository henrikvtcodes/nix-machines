{config, ...}: {
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
      server.root_url = "https://metrics.unicycl.ing";
      server.enable_gzip = true;
      feature_toggles = {
        enable = ["ssoSettingsApi"];
      };
      feature_management = {
        allow_editing = true;
      };
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
        tls.certResolver = "lecf";
      };
      services.grafana = {
        loadBalancer = {
          servers = [{url = "http://localhost:3000";}];
        };
      };
    };
  };

  services.prometheus = {
    enable = true;
    retentionTime = "90d";
    scrapeConfigs = [
      {
        job_name = "Traefik";
        scrape_interval = "15s";
        static_configs = [{targets = ["barnegat:9180"];}];
      }

      {
        job_name = "Woodpecker";
        scrape_interval = "15s";
        static_configs = [{targets = ["barnegat:3008"];}];
      }
    ];
  };
}

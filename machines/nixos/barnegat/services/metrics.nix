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
    globalConfig.external_labels = {
      collectorHostname = config.networking.hostName;
    };
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

      {
        job_name = "CS2210 Aqidorm Project";
        scrape_interval = "3s";
        static_configs = [{targets = ["raspi:9184"];}];
      }
    ];
  };

  services.thanos = {
    sidecar.enable = true;
    query = {
      enable = true;
      endpoints = [
        "ashokan:10901"
        "barnegat:10901"
        "valcour:10901"
      ];
      grpc-address = "0.0.0.0:10903";
      http-address = "0.0.0.0:10904";
    };
  };
}

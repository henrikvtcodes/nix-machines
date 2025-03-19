{
  pkgs,
  config,
  ...
}: {
  services.thanos.sidecar = {
    enable = true;
  };
  environment.systemPackages = with pkgs; [prometheus.cli];
  services.prometheus = {
    enable = true;
    retentionTime = "120d";
    globalConfig.external_labels = {
      collectorHostname = config.networking.hostName;
    };
    scrapeConfigs = [
      {
        job_name = "BGP.Tools - AS215207";
        scrape_interval = "1m";
        scheme = "https";
        metrics_path = "/prom/9bd7e9e4-f70a-48a9-a9a1-06396db1801a";
        static_configs = [{targets = ["bgp.tools"];}];
      }

      {
        job_name = "Node Exporter";
        scrape_interval = "15s";
        static_configs = [
          {
            targets = [
              "marstrand:9100"
              "ashokan:9100"
              "barnegat:9100"
              "valcour:9100"
              "donso:9100"
              "svalbard:9100"
            ];
          }
        ];
      }

      {
        job_name = "AetherNet Node Exporter";
        scrape_interval = "1m";
        scrape_timeout = "30s";
        static_configs = [
          {
            targets = [
              "pete.as215207.net:9100"
              "maple.as215207.net:9100"
              "bay.as215207.net:9100"
              "falaise.as215207.net:9100"
              "strudel.as215207.net:9100"
              "tulip.as215207.net:9100"
              "yeehaw.as215207.net:9100"
            ];
          }
        ];
      }

      {
        job_name = "BIRD Exporter";
        scrape_interval = "1m";
        scrape_timeout = "30s";
        static_configs = [
          {
            targets = [
              "pete.as215207.net:9324"
              "maple.as215207.net:9324"
              "bay.as215207.net:9324"
              "falaise.as215207.net:9324"
              "strudel.as215207.net:9324"
              "tulip.as215207.net:9324"
              "yeehaw.as215207.net:9324"
            ];
          }
        ];
      }

      {
        job_name = "Tailscale";
        scrape_interval = "15s";
        static_configs = [
          {
            targets = [
              "marstrand:5252"
              "ashokan:5252"
              "barnegat:5252"
              "valcour:5252"
              "donso:5252"
              "svalbard:5252"
            ];
          }
        ];
      }

      {
        job_name = "Arista EOS Status";
        scrape_interval = "15s";

        static_configs = [
          {
            targets = [
              "valcour:9396"
            ];
            labels = {
            };
          }
        ];

        relabel_configs = [
          {
            source_labels = ["[__address__]"];
            target_label = "__param_target";
          }
          {
            source_labels = ["[__param_target]"];
            target_label = "instance";
          }
          {
            source_labels = ["[collectors]"];
            target_label = "__param_collectors";
          }
          {
            source_labels = ["__address__"];
            target_label = "valcour:9396";
          }
        ];
      }

      {
        job_name = "Traefik";
        scrape_interval = "15s";
        static_configs = [{targets = ["ashokan:9180"];}];
      }
    ];
  };
}

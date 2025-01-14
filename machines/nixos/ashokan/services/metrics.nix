{...}: {
  services.prometheus = {
    enable = true;
    retentionTime = "90d";

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
    ];
  };
}

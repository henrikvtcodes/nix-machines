{ ... }:
{
  services.prometheus = {
    enable = true;
    exporters.node.enable = true;
    # exporters.unifi = {
    #   enable = true;
    #   # User details are local access only, no need for encryption
    #   unifiUsername = "local-data";
    #   unifiPassword = "promDataExport1";
    #   unifiInsecure = true;
    #   unifiAddress = "http://10.205.0.1:8443";
    # };
    scrapeConfigs = [
      {
        job_name = "BGP.Tools - AS215207";
        scrape_interval = "1m";
        scheme = "https";
        metrics_path = "/prom/9bd7e9e4-f70a-48a9-a9a1-06396db1801a";
        static_configs = [ { targets = [ "bgp.tools" ]; } ];
      }

      {
        job_name = "Node Exporter";
        scrape_interval = "15s";
        static_configs = [
          {
            targets = [
              "localhost:9100"
              "marstrand:9100"
            ];
          }
        ];
      }

      # {
      #   job_name = "Local Unifi Exporter";
      #   scrape_interval = "1m";
      #   static_configs = [ { targets = [ "localhost:9130" ]; } ];
      # }
    ];

  };

  services.grafana = {
    enable = true;
    settings = {
      users = {
        editors_can_admin = true;
        viewers_can_edit = false;
        allow_sign_up = true;
      };
      server.http_addr = "0.0.0.0";
    };
    provision.datasources.path = ./datasources.yml;
  };
}

{ ... }:
{
  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "BGP.Tools - AS215207";
        scrape_interval = "15m";
        scheme = "https";
        metrics_path = "/prom/9bd7e9e4-f70a-48a9-a9a1-06396db1801a";
        static_configs = [ { targets = [ "bgp.tools" ]; } ];
      }
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

{ ... }:
{
  services.paperless = {
    enable = true;
    dataDir = "/data/main/paperless";
    address = "0.0.0.0";
    port = 6443;
  };

  virtualisation.oci-containers = {
    containers.dockge = {
      image = "louislam/dockge:1";
      ports = [ "5001:5001" ];
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "/var/lib/dockge/data:/app/data"
        "/var/lib/dockge/stacks:/var/lib/dockge/stacks"
      ];
      environment = {
        DOCKGE_STACKS_DIR = "/var/lib/dockge/stacks";
      };
    };
  };

  services.prometheus = {
    enable = true;
    exporters.ping = {
      enable = true;
      openFirewall = true;
      settings = {
        targets = [
          "1.1.1.1"
          "8.8.8.8"
          "2001:4860:4860::8888"
          "9.9.9.9"
          "2620:fe::fe"
          "barnegat.unicycl.ing"
          "uvm.edu"
          "discord.com"
          "vl207-wat-mann-c9600.aa.uvm.edu"
        ];
        dns.nameserver = "132.198.201.10";
      };
    };
    retentionTime = "90d";
    scrapeConfigs = [
      {
        job_name = "Ping";
        scrape_interval = "10s";
        static_configs = [ { targets = [ "donso:9427" ]; } ];
      }
    ];
  };

  # systemd.tmpfiles.rules = [
  #   "D /data/main/prometheus2 0751 prometheus prometheus - -"
  #   "L+ /var/lib/prometheus2 - - - - /data/main/prometheus2"
  # ];

  services.couchdb = {
    enable = true;
    databaseDir = "/data/main/couchdb";
    bindAddress = "0.0.0.0";
    adminUser = "obsd";
    adminPassword = "obsdLiveSync"; # DB is not publicly exposed, this is safe
  };
}

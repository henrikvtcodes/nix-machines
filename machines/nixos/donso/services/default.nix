{...}: {
  services.paperless = {
    enable = true;
    dataDir = "/data/main/paperless";
    address = "0.0.0.0";
    port = 6443;
  };

  virtualisation.oci-containers = {
    containers.dockge = {
      image = "louislam/dockge:1";
      ports = ["5001:5001"];
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
        static_configs = [{targets = ["donso:9427"];}];
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
    adminPass = "obsdLiveSync"; # DB is not publicly exposed, this is safe
    extraConfig = ''
      [admins]
      obsd = -pbkdf2-a232e66171a2e07484e1a84f4a1b1a8ed52fc71a,b7f54fee18dcc169cc2c3324b371037a,10

      [couchdb]
      uuid = 36b97a893ab871ed3c991964edee77cf
      max_document_size = 50000000

      [chttpd]
      require_valid_user = true
      max_http_request_size = 4294967296

      [chttpd_auth]
      require_valid_user = true

      [httpd]
      WWW-Authenticate = Basic realm="couchdb"
      enable_cors = true

      [cors]
      credentials = true
      origins = app://obsidian.md,capacitor://localhost,http://localhost
    '';
  };
}

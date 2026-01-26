_: {
  # imports = [ ./thanos.nix ];

  # Users n' Groups
  users.groups.metrics = {};
  users.users.prometheus = {
    isSystemUser = true;
    extraGroups = ["metrics"];
  };

  # Prometheus
  services.prometheus = {
    enable = true;
    retentionTime = "60d";
    extraFlags = [];
    stateDir = "prometheus"; # /var/lib/prometheus (See disk config)
    scrapeConfigs = [];
  };
}

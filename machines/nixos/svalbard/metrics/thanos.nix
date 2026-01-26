_: {
  # General Settings
  users.users.thanos = {
    isSystemUser = true;
    group = "metrics";
  };

  services.thanos = {
    # THANOS SIDECAR
    sidecar = {
      enable = true;
      tsdb.path = "/data/apps/main/metrics/tsdb";
      prometheus.url = "http://localhost:9090";
      http-address = "0.0.0.0:10902";
    };
  };
}

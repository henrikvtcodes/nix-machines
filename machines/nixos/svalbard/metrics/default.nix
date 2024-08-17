{ ... }:
{
  # imports = [ ./thanos.nix ];

  # Users n' Groups
  users.groups.metrics = { };
  users.users.prometheus = {
    isSystemUser = true;
    extraGroups = [ "metrics" ];
  };

  # Prometheus
  services.prometheus = {
    enable = true;
    retentionTime = "60d";
    extraFlags = [ "--storage.tsdb.path=/data/apps/main/metrics" ];
    scrapeConfigs = [ ];
  };
}

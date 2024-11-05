{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.metrics.prometheus;
in {
  options.metrics.prometheus = with lib; {
    enable = mkEnableOption "Enable Prometheus";
    retentionTime = mkOption {
      type = types.str;
      default = "60d";
      description = ''
        How long to keep metrics data.
      '';
    };
    scrapeConfigs = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = ''
        List of scrape configurations.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [prometheus];
    services.prometheus = {
      enable = true;
      retentionTime = cfg.retentionTime;
      scrapeConfigs = cfg.scrapeConfigs;
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.services.betteruptime;
in {
  options.my.services.betteruptime = {
    enable = mkEnableOption {description = "Enable Better Uptime Healthcheck";};
    healthcheckUrlFile = mkOption {
      type = types.path;
      description = ''
        URL to ping for healthchecks.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.timers."betteruptime" = {
      description = "Better Uptime Healthcheck";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "betteruptime.service";
      };
    };

    systemd.services."betteruptime" = {
      description = "Better Uptime Healthcheck";
      script = ''
        ${pkgs.curl}/bin/curl -fsSL $(cat ${cfg.healthcheckUrlFile})
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };
}

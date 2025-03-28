{
  inputs,
  config,
  lib,
  pkgs,
  system,
  ...
}: let
  cfg = config.my.services.eoxporter;
in {
  options.my.services.eoxporter = with lib; {
    enable = mkEnableOption "Enable Eoxporter, a Prometheus Exporter for Arista EOS devices.";
    listenAddress = mkOption {
      type = types.str;
      default = "0.0.0.0:9396";
      description = ''
        The address to listen on.
      '';
    };
    defaultCollectors = mkOption {
      type = types.listOf types.str;
      default = ["version" "power" "temperature" "cooling"];
      description = ''
        Default metrics collectors if the scraper does not specify any
      '';
    };
    eAPIConfigFilePath = mkOption {
      type = types.str;
      default = "/etc/eapi.conf";
      description = ''
        The path to the Arista eAPI configuration file.
      '';
    };
  };

  config = with lib;
    mkIf cfg.enable {
      users = {
        users.eoxporter = {
          isSystemUser = true;
          group = "eoxporter";
        };
        groups.eoxporter = {};
      };

      systemd.services.eoxporter = let
        pkg = inputs.eoxporter.packages.${system}.eoxporter;
      in {
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkg}/bin/eoxporter --listen ${cfg.listenAddress} --eapiConf ${cfg.eAPIConfigFilePath} --collectors ${concatStringsSep "," cfg.defaultCollectors}";
          Restart = "on-failure";
          User = "eoxporter";
          Group = "eoxporter";
        };
      };
    };
}

{
  inputs,
  config,
  lib,
  pkgs,
  system,
  ...
}: {
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
    mkIf config.enable {
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
          Type = "exec";
          ExecStart = "${pkg}/bin/eoxporter -listen-address ${config.listenAddress} -eapi-conf ${config.eAPIConfigFilePath} -default-collectors ${concatStringsSep "," config.defaultCollectors}";
          Restart = "on-failure";
          User = "eoxporter";
          Group = "eoxporter";
        };
      };
    };
}

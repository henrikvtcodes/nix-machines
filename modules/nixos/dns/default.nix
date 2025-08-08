{
  inputs,
  config,
  lib,
  system,
  ...
}: let
  cfg = config.my.services.dns;

  rootCorefile = builtins.readFile ./Corefile;
  
in {
  options.my.services.dns = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable custom Tungsten DNS server";
    };
    package = mkOption {
      type = types.package;
      default = inputs.tungsten.packages.${system}.tungsten;
    };
    controlSocket = mkOption {
      type = types.string;
      default = "/run/tungsten/tungsten.sock";
      description = "The control socket that allows issuing reload and other control commands";
    };
    configFile = mkOption {
      type = types.path;
      default = ./config.pkl;
      description = "The server config file";
    };
  };

  config = with lib;
    mkIf cfg.enable {
      users = {
        users.tungsten = {
          isSystemUser = true;
          group = "tungsten";
          extraGroups = ["tailscale"];
        };
        groups.tungsten = {};
      };

      networking.search = [
        "ts.unicycl.ing"
      ];

      systemd.services.tungsten = let
        caps = [
          "CAP_NET_BIND_SERVICE"
          "CAP_NET_RAW"
        ];
      in {
        wants = ["tailscaled.service"];
        after = ["tailscaled.service"];
        serviceConfig = {
          CapabilityBoundingSet = caps;
          AmbientCapabilities = caps;
          User = "tungsten";
          Group = "tungsten";
          LimitNPROC = 512;
          ProtectHome="read-only";
          ExecStart = "${cfg.package}/bin/tungsten serve --socket=${cfg.controlSocket} --config=${cfg.configFile}";
          ExecReload = "${cfg.package}/bin/tungsten reload --socket=${cfg.controlSocket}";
        };
        stopIfChanged = false;
      };
    };
}

{
  config,
  lib,
  unstable,
  pkgs,
  ...
}: let
  cfg = config.my.services.pocketid;
  pCfg = config.services.pocket-id;

  format = pkgs.formats.keyValue {};
  settingsFile = format.generate "pocket-id-env-vars" pCfg.settings;
in {
  options.my.services.pocketid = with lib; {
    enable = mkEnableOption {
      description = "Enable PocketID";
    };
    domainName = mkOption {
      type = types.str;
      description = "Domain name for PocketID";
    };
    port = mkOption {
      type = types.int;
      default = 7007;
      description = "Port for PocketID";
    };
    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/pocketid/data";
      description = "Path to store PocketID data";
    };
    traefikProxy = mkEnableOption {
      description = "Enable Traefik proxy for PocketID";
    };
  };

  config = lib.mkIf cfg.enable {
    # systemd.tmpfiles.rules = [
    #   "d ${cfg.dataPath} 0764 root podman -"
    #   "d ${cfg.dataPath}/uploads 0764 root podman -"
    #   "z ${cfg.dataPath}/pocket-id.db 0764 root podman -"
    # ];

    # virtualisation.oci-containers.containers.pocketid = {
    #   image = "ghcr.io/pocket-id/pocket-id:v1.9";
    #   ports = [
    #     "0.0.0.0:${toString cfg.port}:1411"
    #   ];
    #   volumes = [
    #     "${cfg.dataPath}:/app/data"
    #   ];
    #   environment = {
    #     APP_URL = "https://${cfg.domainName}";
    #     TRUST_PROXY = "true";
    #     # DB_CONNECTION_STRING = "file:///data/pocket-id.db";
    #     # PORT = toString cfg.port;
    #   };
    # };

    services.pocket-id = {
      # Using the module code copied from nixpkgs unstable but still using some stuff here.
      enable = false;
      package = unstable.pocket-id;
      dataDir = cfg.dataDir;
      settings = {
        APP_URL = "https://${cfg.domainName}";
        TRUST_PROXY = true;
        PORT = toString cfg.port;
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 pocketid pocketid"
    ];

    users = {
      users.pocket-id = {
        isSystemUser = true;
        group = "pocket-id";
        description = "Pocket ID backend user";
        home = cfg.dataDir;
      };

      groups.pocket-id = {};
    };

    systemd.services = {
      pocket-id = {
        description = "Pocket ID";
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
        restartTriggers = [
          pCfg.package
          pCfg.environmentFile
          settingsFile
        ];

        serviceConfig = {
          Type = "simple";
          User = "pocket-id";
          Group = "pocket-id";
          WorkingDirectory = cfg.dataDir;
          ExecStart = lib.getExe pCfg.package;
          Restart = "always";
          EnvironmentFile = [
            pCfg.environmentFile
            settingsFile
          ];

          # Hardening
          AmbientCapabilities = "";
          CapabilityBoundingSet = "";
          DeviceAllow = "";
          DevicePolicy = "closed";
          #IPAddressDeny = "any"; # provides the service through network
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateNetwork = false; # provides the service through network
          PrivateTmp = true;
          PrivateUsers = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          ReadWritePaths = [cfg.dataDir];
          RemoveIPC = true;
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = lib.concatStringsSep " " [
            "~"
            "@clock"
            "@cpu-emulation"
            "@debug"
            "@module"
            "@mount"
            "@obsolete"
            "@privileged"
            "@raw-io"
            "@reboot"
            "@resources"
            "@swap"
          ];
          UMask = "0077";
        };
      };
    };

    services.traefik.dynamicConfigOptions = lib.mkIf cfg.traefikProxy {
      http = {
        routers = {
          pocketid = {
            rule = "Host(`${cfg.domainName}`)";
            service = "pocketid";
            entryPoints = [
              "https"
              "http"
            ];
          };
        };
        services = {
          pocketid = {
            loadBalancer = {
              servers = [{url = "http://localhost:${toString cfg.port}";}];
            };
          };
        };
      };
    };
  };
}

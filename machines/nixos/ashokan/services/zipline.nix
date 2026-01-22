{
  pkgs,
  config,
  ...
}: let
  port = 26007;
  version = "4.4.1";
in {
  # services.zipline = {
  #   enable = true;
  #   settings = {
  #     CORE_PORT = port;
  #     DATASOURCE_TYPE = "s3";
  #     DEBUG = "zipline";
  #   };
  #   environmentFiles = [config.age.secrets.ziplineEnvVars.path];
  # };

  systemd = {
    services.podman-ensure-zipline = {
      serviceConfig = {
        Group = "podman";
        Type = "oneshot";
        Restart = "on-failure";

        ProtectSystem = "strict";
        ProtectHostname = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;

        ReadWritePaths = [
          "/etc/containers"
          "/var/lib/containers"
        ];

        ExecPaths = ["/nix/store"];
        NoExecPaths = ["/"];
      };
      unitConfig = {StartLimitInterval = 5;};
      wantedBy = [
        # "multi-user.target"
        "podman-zipline.service"
        "podman-zipline-db.service"
      ];

      path = [pkgs.podman];
      preStart = "/usr/bin/env sleep 4";
      script = ''
        echo "Creating Zipline network"
        podman network exists zipline || podman network create zipline

        echo "Creating Zipline volumes"
        podman volume exists zipline_pgdata || podman volume create zipline_pgdata
        echo "Init complete"
      '';
    };
    targets.zipline = {
      wants = [
        "podman-ensure-zipline.service"
        "podman-zipline.service"
        "podman-zipline-db.service"
      ];

      wantedBy = ["multi-user.target"];
    };
  };

  virtualisation.oci-containers.containers = {
    zipline-db = {
      image = "postgres:16-alpine";
      autoStart = true;
      extraOptions = [
        "--network=zipline"
      ];

      environment = {
        POSTGRES_USER = "zipline";
        POSTGRES_PASSWORD = "zipline";
        POSTGRES_DB = "zipline";
      };
      volumes = [
        "zipline_pgdata:/var/lib/postgresql/data"
      ];
    };
    zipline = {
      image = "ghcr.io/diced/zipline:${version}";
      autoStart = true;
      extraOptions = [
        "--network=zipline"
      ];
      dependsOn = ["zipline-db"];

      environment = {
        DATABASE_URL = "postgres://zipline:zipline@zipline-db:5432/zipline";
      };
      environmentFiles = [config.age.secrets.ziplineEnvVars.path];
      ports = [
        "127.0.0.1:${toString port}:3000"
      ];
    };
  };

  services.caddy.virtualHosts."share.unicycl.ing" = {
    extraConfig = ''
      reverse_proxy http://localhost:${toString port}
    '';
  };
}

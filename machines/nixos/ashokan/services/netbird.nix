{config, ...}: let
  nbDomain = "vpn.unicycl.ing";
  nbDashboardPort = 13203;
in {
  services.netbird.server = {
    coturn = {
      enable = true;
      useAcmeCertificates = true;
      domain = "turn.ash.unicycl.ing";
      passwordFile = config.age.secrets.netbirdTurnUserPassword.path;
    };

    management = {
      enable = true;
      port = 13201;
      domain = nbDomain;
      turnDomain = "turn.nyc.unicycl.ing";
      oidcConfigEndpoint = "https://oidc.unicycl.ing/.well-known/openid-configuration";
      dnsDomain = "int.unicycl.ing";
      disableSingleAccountMode = true;
    };

    signal = {
      enable = true;
      port = 13202;
      domain = nbDomain;
    };

    dashboard = {
      enable = true;
      domain = nbDomain;
      managementServer = "https://${nbDomain}";
      settings = {
        AUTH_AUTHORITY = "oidc.unicycl.ing";
      };
    };
  };

  services.nginx = {
      enable = true;

      virtualHosts.${config.services.netbird.server.dashboard.domain}.listen = [
        {
          addr = "127.0.0.1";
          port = nbDashboardPort;
        }
      ];
    };

  services.traefik.dynamicConfigOptions.http = {
    services = {
      netbird-management = {
        # h2c scheme is required for gRPC
        loadBalancer.servers = [{url = "h2c://localhost:${toString config.services.netbird.management.port}";}];
      };
      netbird-api = {
        loadBalancer.servers = [{url = "http://localhost:${toString config.services.netbird.management.port}";}];
      };
      netbird-signal = {
        # h2c scheme is required for gRPC
        loadBalancer.servers = [{url = "h2c://localhost:${toString config.services.netbird.signal.port}";}];
      };
      netbird-dashboard = {
        loadBalancer.servers = [{url = "http://localhost:${toString nbDashboardPort}";}];
      };
    };
    routers = {
      netbird-management = {
        rule = "Host(`${nbDomain}`) && PathPrefix(`/management.ManagementService/`)";
        service = "netbird-management";
        entryPoints = [
          "https"
          "http"
        ];
      };
      netbird-api = {
        rule = "Host(`${nbDomain}`) && PathPrefix(`/api`)";
        service = "netbird-api";
        entryPoints = [
          "https"
          "http"
        ];
      };

      netbird-signal = {
        rule = "Host(`${nbDomain}`) && PathPrefix(`/signalexchange.SignalExchange/`)";
        service = "netbird-signal";
        entryPoints = [
          "https"
          "http"
        ];
      };

      netbird-dashboard = {
        rule = "Host(`${nbDomain}`)";
        service = "netbird-dashboard";
        entryPoints = [
          "https"
          "http"
        ];
      };
    };
  };
}

{config, ...}: let 
  nbDomain = "vpn.unicycl.ing";
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
    };

    signal = {
      enable = true;
      port = 13202;
      domain = nbDomain;
    };

    dashboard = {
      enable = true;
      port = 13203;
      domain = nbDomain;
    };
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
        loadBalancer.servers = [{url = "http://localhost:${toString config.services.netbird.dashboard.port}";}];
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

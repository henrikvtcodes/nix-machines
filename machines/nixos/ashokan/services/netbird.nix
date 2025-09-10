{
  config,
  lib,
  pkgs,
  ...
}: let
  nbDomain = "vpn.unicycl.ing";
  nbDashboardPort = 13203;
in {
  services.netbird.server = {
    domain = nbDomain;

    coturn = {
      enable = true;
      useAcmeCertificates = true;
      domain = "turn.ash.unicycl.ing";
      passwordFile = config.age.secrets.netbirdTurnUserPassword.path;
    };

    management = {
      enable = true;
      port = 13201;
      metricsPort = 13291;
      domain = nbDomain;
      turnDomain = "turn.nyc.unicycl.ing";
      oidcConfigEndpoint = "https://oidc.unicycl.ing/.well-known/openid-configuration";
      dnsDomain = "int.unicycl.ing";
      disableSingleAccountMode = true;
      settings = {
        DataStoreEncryptionKey = {
          _secret = config.age.secrets.netbirdDSEKey.path;
        };

        Stuns = [
          {
            Proto = "udp";
            URI = "stun:turn.nyc.unicycl.ing:3478";
            Username = "";
            Password = null;
          }
          {
            Proto = "udp";
            URI = "stun:turn.ash.unicycl.ing:3478";
            Username = "";
            Password = null;
          }
        ];

        TURNConfig = {
          Turns = [
            {
              Proto = "udp";
              URI = "turn:turn.ash.unicycl.ing:3478";
              Username = "netbird";
              Password = {
                _secret = config.age.secrets.netbirdTurnUserPassword.path;
              };
            }
            {
              Proto = "udp";
              URI = "turn:turn.nyc.unicycl.ing:3478";
              Username = "netbird";
              Password = {
                _secret = config.age.secrets.netbirdTurnUserPassword.path;
              };
            }
          ];
        };

        IdpManagerConfig = {
          ClientConfig = {
            ClientID = "a08f0cef-03d2-4380-836f-b4d71da2d609";
            ClientSecret = {
              _secret = config.age.secrets.netbirdOIDCSecret.path;
            };
          };
        };
      };
    };

    signal = {
      enable = true;
      port = 13202;
      metricsPort = 13292;
    };
  };

  # Dashboard hosted in Podman Container
  virtualisation.oci-containers.containers = {
    netbird-dashboard = {
      image = "netbirdio/dashboard:v2.18.0";
      autoStart = true;
      environment = {
        USE_AUTH0 = "false";
        AUTH_AUTHORITY = "https://oidc.unicycl.ing";
        AUTH_CLIENT_ID = "a08f0cef-03d2-4380-836f-b4d71da2d609";
        AUTH_AUDIENCE = "none";
        NETBIRD_MGMT_API_ENDPOINT = "https://${nbDomain}";
        AUTH_SUPPORTED_SCOPES = "openid profile email";
        NETBIRD_TOKEN_SOURCE = "idToken";
      };
      extraOptions = ["--runtime=${pkgs.gvisor}/bin/runsc"];
      ports = ["${toString nbDashboardPort}:80"];
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    services = {
      netbird-management = {
        # h2c scheme is required for gRPC
        loadBalancer.servers = [{url = "h2c://localhost:${toString config.services.netbird.server.management.port}";}];
      };
      netbird-api = {
        loadBalancer.servers = [{url = "http://localhost:${toString config.services.netbird.server.management.port}";}];
      };
      netbird-signal = {
        # h2c scheme is required for gRPC
        loadBalancer.servers = [{url = "h2c://localhost:${toString config.services.netbird.server.signal.port}";}];
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

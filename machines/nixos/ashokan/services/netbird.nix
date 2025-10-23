{
  config,
  lib,
  pkgs,
  ...
}: let
  nbDomain = "vpn.unicycl.ing";
  nbDashboardPort = 13203;
  clientId = "xcFITirsKHIIFIAtuAOd6SXkCrlS31GOcEPwanYE";
  idpDomain = "idp.unicycl.ing";
in {

  my.services.caddy.verbose = true;

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
      oidcConfigEndpoint = "https://${idpDomain}/application/o/netbird/.well-known/openid-configuration";
      dnsDomain = "int.unicycl.ing";
      disableSingleAccountMode = true;
      settings = {
        DataStoreEncryptionKey._secret = config.age.secrets.netbirdDSEKey.path;

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
              Password._secret = config.age.secrets.netbirdTurnUserPassword.path;
            }
            {
              Proto = "udp";
              URI = "turn:turn.nyc.unicycl.ing:3478";
              Username = "netbird";
              Password._secret = config.age.secrets.netbirdTurnUserPassword.path;
            }
          ];
        };
        HttpConfig = {
          AuthAudience = clientId;
          AuthUserIDClaim = "sub";
        };

        IdpManagerConfig = {
          ManagerType = "authentik";
          ClientConfig = {
            Issuer = "https://${idpDomain}/application/o/netbird/";
            TokenEndpoint = "https://${idpDomain}/application/o/token/";
            ClientID = clientId;
            ClientSecret._secret = config.age.secrets.netbirdOIDCSecret.path;
          };
          ExtraConfig = {
            Password._secret = config.age.secrets.netbirdIDPServiceUserPassword.path;
            Username = "netbird";
          };
        };

        PKCEAuthorizationFlow.ProviderConfig = {
          Audience = clientId;
          ClientID = clientId;
          ClientSecret = "";
          AuthorizationEndpoint = "https://${idpDomain}/application/o/authorize/";
          TokenEndpoint = "https://${idpDomain}/application/o/token/";
          RedirectURLs = ["http://localhost:53000"];
        };
      };
    };

    signal = {
      enable = true;
      port = 13202;
      metricsPort = 13292;
    };

    dashboard = {
      enable = true;
      # managementServer = "https://${nbDomain}";
      # domain = "localhost";
      managementServer = "";
      domain = "";
      settings = {
        AUTH_AUTHORITY = "https://${idpDomain}/application/o/netbird/";
        AUTH_SUPPORTED_SCOPES = "openid profile email offline_access api";
        AUTH_AUDIENCE = clientId;
        AUTH_CLIENT_ID = clientId;
        
      };
    };
  };

  services.caddy.virtualHosts."${nbDomain}" = {
    extraConfig = ''
      root * ${config.services.netbird.server.dashboard.finalDrv}

      reverse_proxy /signalexchange.SignalExchange/* h2c://localhost:${toString config.services.netbird.server.signal.port}
      reverse_proxy /api/* localhost:${toString config.services.netbird.server.management.port}
      reverse_proxy /management.ManagementService/* h2c://localhost:${toString config.services.netbird.server.management.port}
      
      file_server

      header * {
      	Strict-Transport-Security "max-age=3600; includeSubDomains; preload"
      	X-Content-Type-Options "nosniff"
      	X-Frame-Options "DENY"
      	X-XSS-Protection "1; mode=block"
      	-Server
      	Referrer-Policy strict-origin-when-cross-origin
      }
    '';
  };
}

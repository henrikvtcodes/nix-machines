{ config, ... }:
{
  imports = [
    # ./auth.nix
    ./metrics.nix
    ./ci.nix
  ];

  svcs.pocketid = {
    enable = true;
    domainName = "oidc.unicycl.ing";
    frontendApiPort = 7000;
    adminApiPort = 7070;
    traefikProxy = true;
  };

  services.traefik = {
    enable = true;
    # Contains cloudflare API key for ACME DNS-01 Challenge
    environmentFiles = [ config.age.secrets.cfDnsApiToken.path ];
    staticConfigOptions = {
      entrypoints = {
        http.address = ":80";
        https = {
          address = ":443";
          http.tls = {
            certResolver = "lecf";
          };
        };

        metrics.address = ":9180";
      };

      providers.docker = {
        endpoint = "unix:///var/run/podman/podman.sock";
        exposedByDefault = false;
      };

      certificatesResolvers = {
        # Let's Encrypt via Cloudflare
        lecf = {
          acme.storage = "${config.services.traefik.dataDir}/acme-lecf.json";
          acme.dnsChallenge = {
            provider = "cloudflare";
            delayBeforeCheck = 10;
            resolvers = [ "8.8.8.8:53" ];
          };
        };
      };
      api = {
        insecure = true;
        dashboard = true;
      };
      log = {
        level = "INFO";
        noColor = false;
      };
      metrics.prometheus = {
        entryPoint = "metrics";
        addEntryPointsLabels = true;
        addServicesLabels = true;
        buckets = [
          0.1
          0.3
          1.2
          5.0
        ];
      };
    };
  };
  users.users.traefik.extraGroups = [
    "acme"
    "docker"
    "podman"
  ];
  networking.firewall.interfaces.ens3.allowedTCPPorts = [
    22
    80
    443
  ];
}

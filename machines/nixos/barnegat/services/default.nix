{ config, ... }:
{
  imports = [
    # ./auth.nix
    ./metrics.nix
  ];

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
            "domains[0]".main = "unicycl.ing";
            "domains[0]".sans = "*.unicycl.ing";
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
  ];
  networking.firewall.interfaces.ens3.allowedTCPPorts = [
    22
    80
    443
  ];
}

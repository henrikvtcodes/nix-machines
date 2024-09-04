{ config, ... }:
{
  imports = [
    # ./auth.nix
    ./metrics.nix
  ];

  # security.acme = {
  #   acceptTerms = true;
  #   defaults.email = "acme@henrikvt.com";
  #   certs."domain.com" = {
  #     domain = "unicycl.ing";
  #     extraDomainNames = [ "*.domain.com" ];
  #     dnsProvider = "cloudflare";
  #     dnsPropagationCheck = true;
  #     credentialsFile = "/etc/nixos/credentials.txt";
  #   };
  # };

  services.traefik = {
    enable = true;
    # Contains cloudflare API key for ACME DNS-01 Challenge
    environmentFiles = [ config.age.secrets.cfDnsApiToken.path ];
    staticConfigOptions = {
      entrypoints = {
        http.address = ":80";
        https.address = ":443";
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
    };
  };
  users.users.traefik.extraGroups = [ "acme" ];
  networking.firewall.interfaces.ens3.allowedTCPPorts = [
    22
    80
    443
  ];
}

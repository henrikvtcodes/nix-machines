{ config, ... }:
{
  imports = [
    # ./auth.nix
    ./metrics.nix
  ];

  services.traefik = {
    enable = true;
    # Contains cloudflare API key for ACME DNS-01 Challenge
    environmentFiles = [ config.age.secrets.tailscaleAuthKey.path ];
    staticConfigOptions = {
      entrypoints = {
        http.address = ":80";
        https.address = ":443";
      };
      certificatesResolvers = {
        # Let's Encrypt via Cloudflare
        lecf = {
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
    };
  };
  users.users.traefik.extraGroups = [ "acme" ];
  networking.interfaces.ens3.allowedTCPPorts = [
    22
    80
    443
  ];
}

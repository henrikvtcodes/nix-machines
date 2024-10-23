{ config, ... }:
{
  imports = [
    ./metrics.nix
    ./proxy.nix
  ];

  svcs.pocketid = {
    enable = true;
    domainName = "oidc.unicycl.ing";
    frontendApiPort = 7000;
    adminApiPort = 7070;
    traefikProxy = true;
  };

  svcs.ci-server = {
    enable = true;
    domain = "ci.unicycl.ing";
    environmentFiles = [
      config.age.secrets.ciSecrets.path
      config.age.secrets.ciAgentSecrets.path
    ];
    enableTraefik = true;
    allowSignup = true;
  };
}

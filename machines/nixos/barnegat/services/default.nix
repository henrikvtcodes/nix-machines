{
  config,
  pkgs-unstable,
  ...
}: {
  imports = [
    ./metrics.nix
    ./proxy.nix
  ];

  my.services.pocketid = {
    enable = true;
    domainName = "oidc.unicycl.ing";
    frontendApiPort = 7000;
    adminApiPort = 7070;
    traefikProxy = true;
  };

  my.services.ci-server = {
    enable = true;
    domain = "ci.unicycl.ing";
    environmentFiles = [
      config.age.secrets.ciSecrets.path
      config.age.secrets.ciAgentSecrets.path
    ];
    enableTraefik = true;
    allowSignup = true;
  };

  services.woodpecker-server.package = pkgs-unstable.woodpecker-server;
}

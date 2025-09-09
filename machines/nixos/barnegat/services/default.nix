{
  config,
  pkgs-unstable,
  ...
}: {
  imports = [
    ./metrics.nix
    ./proxy.nix
    ./netbird.nix
  ];

  my.services.pocketid = {
    enable = true;
    domainName = "oidc.unicycl.ing";
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

  services.atuin = {
    enable = true;
    openRegistration = true;
    host = "0.0.0.0";
    port = 22022;
    database.createLocally = true;
  };

  services.woodpecker-server.package = pkgs-unstable.woodpecker-server;
}

{
  config,
  pkgs,
  ...
}: {
  services.nginx = {
    enable = true;
    package = pkgs.nginxQuic;
  };

  security.acme = {
    defaults.email = "acme@unicycl.ing";
    acceptTerms = true;

    certs."unicycl.ing" = {
      dnsProvider = "cloudflare";
      environmentFile = config.age.secrets.cfDnsApiToken.path;
      dnsResolver = "8.8.8.8:53";
      dnsPropagationCheck = true;
    };
  };
}

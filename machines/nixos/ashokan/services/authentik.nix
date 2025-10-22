{config, ...}: {
  services.authentik = {
    enable = true;
    environmentFile = config.age.secrets.authentikEnvVars.path;
    createDatabase = true;
    settings = {
      email = {
        host = "smtp.improvmx.com";
        port = 587;
        username = "auth-noreply@unicycl.ing";
        use_tls = true;
        use_ssl = false;
        from = "auth-noreply@unicycl.ing";
      };
      storage.media = {
        backend = "s3";
      };
      disable_startup_analytics = true;
      avatars = "initials";
    };
  };

  services.caddy.virtualHosts."idp.unicycl.ing" = {
    extraConfig = ''
      reverse_proxy https://localhost:9443
    '';
  };
}
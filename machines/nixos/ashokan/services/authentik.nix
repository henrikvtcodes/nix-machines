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

  systemd.services.authentik-migrate.after = ["redis-authentik.service" "postgresql.service"];
  systemd.targets.authentik = {
    wantedBy = ["multi-user.target"];
    wants = ["authentik.service" "authentik-migrate.service" "authentik-worker.service"];
    after = ["redis-authentik.service" "postgresql.service" "network-online.target"];
  };

  services.caddy.virtualHosts."idp.unicycl.ing" = {
    extraConfig = ''
      reverse_proxy http://localhost:9000
    '';
  };
}

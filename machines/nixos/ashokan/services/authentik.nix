{
  config,
  lib,
  ...
}: {
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
      disable_startup_analytics = true;
    };
  };

  systemd.services.authentik-migrate.after = ["redis-authentik.service" "postgresql.service"];
  systemd.services.authentik-migrate.before = lib.mkForce ["authentik.service"];
  systemd.services.authentik.after = ["authentik-migrate.service"];

  services.caddy.virtualHosts."idp.unicycl.ing" = {
    extraConfig = ''
      reverse_proxy http://localhost:9000
    '';
  };
}

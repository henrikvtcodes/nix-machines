{pkgs, config, ...} :let

  port = 26007;
in
 {
  services.zipline = {
    enable = true;
    settings = {
      CORE_PORT = port;
    };
    environmentFiles = [ config.age.secrets.ziplineEnvVars.path];
  };


  services.caddy.virtualHosts."share.unicycl.ing" = {
    extraConfig = ''
      reverse_proxy http://localhost:${toString port}
    '';
  };
}
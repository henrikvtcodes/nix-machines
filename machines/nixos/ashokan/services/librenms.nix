{config, lib, ...}: let
  hostname = "nms.unicycl.ing";
  internalport = 18008;
in {
  services.librenms = {
    enable = true;
    inherit hostname;
    database.createLocally = true;
    database.passwordFile = config.age.secrets.librenmsDbPw.path;

    poolConfig = {
      "listen.owner" = config.services.caddy.user;
      "listen.group" = config.services.caddy.group;

      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.max_spare_servers" = 4;
      "pm.min_spare_servers" = 2;
      "pm.start_servers" = 2;
    };
  };

  services.caddy.virtualHosts."${hostname}" = {
    extraConfig = ''
      # reverse_proxy localhost:${toString internalport}
      root * ${config.services.librenms.finalPackage}/html
      encode
      php_fastcgi unix/${config.services.phpfpm.pools."librenms".socket} {
        index index.php
      }
      file_server
    '';
  };
}

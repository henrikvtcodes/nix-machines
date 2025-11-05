{config, ...}: let
  hostname = "nms.unicycl.ing";
  internalport = 18008;
in {
  services.librenms = {
    enable = true;
    inherit hostname;
    database.createLocally = true;
    database.passwordFile = config.age.secrets.librenmsDbPw.path;
    nginx.listen = [
      {
        addr = "127.0.0.1";
        port = internalport;
      }
    ];

    poolConfig = {
      "listen.owner" = config.services.caddy.user;
      "listen.group" = config.services.caddy.group;
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

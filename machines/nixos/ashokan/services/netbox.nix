{config,pkgs, ...}: {
  services.netbox = {
    enable = true;
    port = 22022;
    package = pkgs.netbox_4_2;
    secretKeyFile = config.age.secrets.netboxSecretKey.path;
  };

  services.traefik.dynamicConfigOptions = {
    http = {
      routers = {
        netbox = {
          rule = "Host(`netbox.unicycl.ing`)";
          service = "netbox";
          entryPoints = [
            "https"
            "http"
          ];
        };
      };
      services = {
        netbox = {
          loadBalancer = {
            servers = [{url = "http://localhost:${toString config.services.netbox.port}";}];
          };
        };
      };
    };
  };
}

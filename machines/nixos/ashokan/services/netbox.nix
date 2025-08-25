{
  config,
  pkgs,
  ...
}: {
  services.netbox = {
    enable = true;
    port = 22022;
    package = pkgs.netbox_4_2;
    secretKeyFile = config.age.secrets.netboxSecretKey.path;
  };

  services.nginx = {
    enable = true;
    group = "netbox";
    virtualHosts."netbox-static" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 9001;
        }
      ];
      locations."/" = {root = "${config.services.netbox.dataDir}";};
    };
  };

  services.traefik.dynamicConfigOptions = let
    domain = "netbox.unicycl.ing";
  in {
    http = {
      routers = {
        netbox = {
          rule = "Host(`${domain}`)";
          service = "netbox";
          entryPoints = [
            "https"
            "http"
          ];
        };
        "netbox-static" = {
          rule = "Host(`${domain}`) && PathPrefix(`/static`)";
          service = "netbox-static";
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
        "netbox-static" = {
          loadBalancer.servers = [{url = "http://127.0.0.1:9001";}];
        };
      };
    };
  };
}

{config,pkgs, ...}: {
  services.netbox = {
    enable = true;
    port = 22022;
    package = pkgs.netbox_4_2;
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
            servers = [{url = "http://localhost:${config.services.stirling-pdf.port}";}];
          };
        };
      };
    };
  };
}

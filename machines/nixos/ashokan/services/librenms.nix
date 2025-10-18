{config, ...}:
let 

hostname = "librenms.unicycl.ing";
internalport = 18008;

in
 {

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
  };

  services.traefik.dynamicConfigOptions = {
    http = {
      routers = {
        librenms = {
          rule = "Host(`${hostname}`)";
          service = "librenms";
          entryPoints = [
            "https"
            "http"
          ];
        };
      };
      services = {
        librenms = {
          loadBalancer = {
            servers = [{url = "http://localhost:${toString internalport}";}];
          };
        };
      };
    };
  };

}

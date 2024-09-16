{ pkgs, config, ... }:
let
  domain = "ci.unicycl.ing";
in
{
  environment.systemPackages = with pkgs; [ woodpecker-cli ];

  services.woodpecker-server = {
    enable = true;
    environment = {
      WOODPECKER_HOST = "https://${domain}";
      WOODPECKER_SERVER_ADDR = ":3007";
      WOODPECKER_OPEN = "false";
      WOODPECKER_ADMIN = "henrikvtcodes";
      WOODPECKER_ORGS = "orangeunilabs";
      WOODPECKER_METRICS_SERVER_ADDR = ":3008";
    };
    environmentFile = [ config.age.secrets.ciSecrets.path ];
  };

  services.traefik.dynamicConfigOptions = {
    http = {
      routers.woodpecker = {
        rule = "Host(`${domain}`)";
        service = "woodpecker";
        entryPoints = [
          "https"
          "http"
        ];
        tls.certResolver = "lecf";
      };
      services.woodpecker = {
        loadBalancer = {
          servers = [ { url = "http://localhost:3007"; } ];
        };
      };
    };
  };
}

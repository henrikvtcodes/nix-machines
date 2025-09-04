{config, ...}: {
  services.mealie = {
    enable = true;
    port = 16099;
    credentialsFile = config.age.secrets.mealieCredentials.path;
    settings = rec {
      TZ = "America/New_York";
      ALLOW_SIGNUP = "false";
      SMTP_HOST = "smtp.improvmx.com";
      SMTP_FROM_NAME = "mealie";
      SMTP_FROM_EMAIL = "mealie@unicycl.ing";
      SMTP_USER = SMTP_FROM_EMAIL;
      # Password defined in credentials file
    };
  };

  services.traefik.dynamicConfigOptions = let
    domain = "mealie.unicycl.ing";
  in {
    http = {
      routers = {
        mealie = {
          rule = "Host(`${domain}`)";
          service = "mealie";
          entryPoints = [
            "https"
            "http"
          ];
        };
      };
      services = {
        mealie = {
          loadBalancer = {
            servers = [{url = "http://localhost:${toString config.services.mealie.port}";}];
          };
        };
      };
    };
  };
}

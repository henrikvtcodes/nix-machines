{
  config,
  pkgs,
  ...
}: let
  domain = "netbox.unicycl.ing";
in {
  services.netbox = {
    enable = true;
    port = 22022;
    package = pkgs.netbox_4_2;
    secretKeyFile = config.age.secrets.netboxSecretKey.path;
  };

  users.users.caddy.extraGroups = ["netbox"];
  systemd.services.caddy.serviceConfig = {SupplementaryGroups = ["netbox"];};

  services.caddy.virtualHosts."${domain}" = {
    extraConfig = ''
      import default
      handle /static* {
          root * ${config.services.netbox.dataDir}
          file_server
      }
      handle {
        reverse_proxy localhost:${toString config.services.netbox.port}
      }
    '';
  };
}

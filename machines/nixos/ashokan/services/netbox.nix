{
  config,
  pkgs,
  unstable,
  ...
}: let
  domain = "netbox.unicycl.ing";
in {
  services.netbox = {
    enable = true;
    port = 22022;
    package = unstable.netbox;
    secretKeyFile = config.age.secrets.netboxSecretKey.path;
    plugins = python3Packages: with python3Packages; [
      # netbox-bgp
      netbox-routing
      netbox-dns
      netbox-floorplan-plugin
      # netbox-topology-views
      netbox-reorder-rack
    ];
    settings = {
      "PLUGINS" = [
        # "netbox_bgp"
        "netbox_routing"
        "netbox_dns"
        "netbox_floorplan"
        "netbox_reorder_rack"
      ];
    };
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

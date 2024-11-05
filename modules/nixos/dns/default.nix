{ config, lib, ... }:
let

  cfg = config.svcs.dns;
in
{
  options.svcs.dns = with lib; {
    enable = mkEnableOption "Enable the DNS service";
    enableMetrics = mkEnableOption "Enable the Prometheus Unbound Exporter";
    tailscale = {
      tailnetRoot = mkOption {
        type = types.str;
        default = "reindeer-porgy.ts.net";
        description = "The root domain for the Tailscale network";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.unbound = {
      enable = true;
      localControlSocketPath = "/run/unbound/unbound.ctl";
      group = "unbound";
      settings = {
        server = {
          interface = [
            "127.0.0.1"
            "0.0.0.0"
            "::1"
            "::"
          ];
        };
        forward-zone = [
          {
            name = "unicycl.ing";
            forward-addr = "1.1.1.1@853#cloudflare-dns.com";
          }
          {
            name = ".";
            forward-addr = [
              "9.9.9.10@853#dns10.quad9.net"
              "149.112.112.10@853#dns10.quad9.net"
              "2620:fe::10@853#dns10.quad9.net"
              "2620:fe::fe:10@853#dns10.quad9.net"
            ];
          }
        ];
        remote-control.control-enable = false;
      };
    };

    services.prometheus.exporters.unbound = lib.mkIf cfg.enableMetrics {
      enable = true;
      group = "unbound";
      unbound.host = "unix://${config.services.unbound.localControlSocketPath}";
    };

    users.groups.unbound = { };
  };
}

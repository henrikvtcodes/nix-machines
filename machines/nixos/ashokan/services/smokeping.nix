{
  config,
  pkgs,
  ...
}: let
  hostname = "sp.ash.unicycl.ing";
  internalport = 28008;
in {
  services.smokeping = {
    enable = true;
    webService = true;
    probeConfig = ''
      + FPing
      binary = ${config.security.wrapperDir}/fping

      +DNS
      binary = ${pkgs.dig}/bin/dig
      lookup = ${config.networking.fqdnOrHostName}

    '';
    targetConfig = ''
      probe = FPing

        + UVM
        menu = UVM
        title = UVM Infra
        probe = DNS

        ++ ns1.uvm
        menu = ns1
        title = UVM NS1
        server = ns1.uvm.edu
        host = ${config.networking.fqdnOrHostName}

        ++ ns2.uvm
        menu = ns2
        title = UVM NS2
        server = ns2.uvm.edu
        host = ${config.networking.fqdnOrHostName}


        + DNS
        probe = DNS
        menu = DNS
        title = DNS Latency Probes

        ++ all-cloudflare
        menu = all-cloudflare
        title = All cloudflare DNS
        host = /DNS/cloudflare0 /DNS/cloudflare1

        ++ cloudflare0
        menu = cloudflare0
        title = cloudflare 1.0.0.1 DNS performance
        server = 1.0.0.1
        host = ${config.networking.fqdnOrHostName}

        ++ cloudflare1
        menu = cloudflare1
        title = cloudflare 1.1.1.1 DNS performance
        server = 1.1.1.1
        host = ${config.networking.fqdnOrHostName}

        ++ all-quad9
        menu = all-quad9
        title = All quad9 DNS
        host = /DNS/quad9 /DNS/quad112

        ++ quad9
        menu = quad9
        title = quad9 9.9.9.9 DNS performance
        server = 9.9.9.9
        host = ${config.networking.fqdnOrHostName}

        ++ quad112
        menu = quad112
        title = quad9 149.112.112.112 DNS performance
        server = 149.112.112.112
        host = ${config.networking.fqdnOrHostName}

    '';
  };

  services.nginx.virtualHosts."smokeping".listen = [
    {
      addr = "127.0.0.1";
      port = internalport;
    }
  ];

  services.traefik.dynamicConfigOptions = {
    http = {
      routers = {
        smokeping = {
          rule = "Host(`${hostname}`)";
          service = "smokeping";
          entryPoints = [
            "https"
            "http"
          ];
        };
      };
      services = {
        smokeping = {
          loadBalancer = {
            servers = [{url = "http://localhost:${toString internalport}";}];
          };
        };
      };
    };
  };
}

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
    cgiUrl = "https://${hostname}/smokeping.cgi";
    probeConfig = ''
      + FPing
      binary = ${config.security.wrapperDir}/fping

      + Curl
      binary = ${pkgs.curl}/bin/curl
      urlformat = http://%host%/
      timeout = 10
      step = 300
      extraargs = --silent
      follow_redirects = yes
      include_redirects = no

      + DNS
      binary = ${pkgs.bind.dnsutils}/bin/dig
      timeout = 15
      step = 300
    '';
    targetConfig = ''
      probe = FPing

        + UVM
        menu = UVM
        title = UVM Infra
        probe = DNS

        ++ ns1-uvm
        menu = ns1
        title = UVM NS1
        server = ns1.uvm.edu
        host = ${config.networking.fqdnOrHostName}

        ++ ns2-uvm
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

  systemd.services.smokeping = {
    serviceConfig = {
      # Resource limits
      Slice = "smokeping.slice";
      MemoryHigh = "200M";
      MemoryMax = "300M";
      CPUQuota = "20%";
      TasksMax = 200;

      # Process limits
      LimitNOFILE = 1024;
      LimitNPROC = 100;

      # Security restrictions
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      ProtectKernelLogs = true;
      PrivateDevices = true;
      RestrictRealtime = true;
      # RestrictSUIDSGID = true;  # Disabled - smokeping needs SUID wrapper for ping
      RestrictNamespaces = true;
      LockPersonality = true;
      # MemoryDenyWriteExecute = true;  # Disabled - interferes with DNS resolution
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];

      # Additional security restrictions
      RemoveIPC = true;  # Clean up IPC objects
      UMask = "0077";  # Restrict file permissions
      SystemCallFilter = [ "@system-service" "~@privileged" "~@mount" "~@debug" "~@module" "~@reboot" "~@swap" "~@clock" "~@cpu-emulation" "~@obsolete" ];  # Allow raw-io for IPv6 ping
      CapabilityBoundingSet = [ "CAP_NET_RAW" "CAP_NET_BIND_SERVICE" ];  # Only network capabilities needed
      ProtectProc = "default";  # Allow access to process info for DNS resolution
      ProcSubset = "all";  # Allow access to all process info
      ProtectHostname = true;  # Prevent hostname changes
      ProtectClock = true;  # Prevent clock changes

      # File system restrictions - allow access to dig
      ReadWritePaths = [
        "/var/lib/smokeping"
        "/var/log"
        "/run"
      ];
      ReadOnlyPaths = [
        "/etc/smokeping.conf"
        "/nix/store"
        "${pkgs.curl}"
        "${config.services.smokeping.package}"
        "${config.security.wrapperDir}"
        "/etc/resolv.conf"
        "/etc/hosts"
        "/etc/nsswitch.conf"
        "/etc/ssl"
        "/etc/ca-bundle.crt"
        "/etc/ssl/certs"
      ];

      # User/group restrictions
      User = "smokeping";
      Group = "smokeping";
      SupplementaryGroups = [ "smokeping" ];

      # Restart policy
      Restart = "on-failure";
      RestartSec = "10s";

      # Nice priority (lower number = higher priority)
      Nice = 10;

      # Required by smokeping module
      ExecStart = "${config.services.smokeping.package}/bin/smokeping --config=/etc/smokeping.conf --nodaemon";
    };

    # Add curl package to the service environment
    path = [ pkgs.curl pkgs.bind.dnsutils ];
    environment = {
      # Ensure DNS resolution works
      NSS_WRAPPER_PASSWD = "/etc/passwd";
      NSS_WRAPPER_GROUP = "/etc/group";
      LD_LIBRARY_PATH = "${pkgs.curl}/lib";
    };
  };

  services.nginx.virtualHosts."smokeping" = {
    serverName = hostname;
    listen = [
      {
        addr = "127.0.0.1";
        port = internalport;
      }
    ];
  };

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
            servers = [{url = "http://127.0.0.1:${toString internalport}";}];
          };
        };
      };
    };
  };
}

#
# nixos/hp/hp4/smokeping.nix
#
# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/smokeping.nix
# https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/monitoring/prometheus/exporters/smokeping.nix
# https://oss.oetiker.ch/smokeping/doc/smokeping_examples.en.html
# https://oss.oetiker.ch/smokeping/probe/Curl.en.html
# https://oss.oetiker.ch/smokeping/probe/DNS.en.html
{
  config,
  lib,
  pkgs,
  ...
}: let
  targets = {
    # DNS Servers - ICMP ping testing
    "DNSServers" = {
      title = "DNS Server Connectivity (ICMP Ping)";
      menu = "DNS Servers";
      targets = {
        "Google_DNS_IPv4" = {
          name = "Google DNS IPv4";
          host = "8.8.8.8";
        };
        "Google_DNS_IPv6" = {
          name = "Google DNS IPv6";
          host = "2001:4860:4860::8888";
        };
        "Cloudflare_DNS_IPv4" = {
          name = "Cloudflare DNS IPv4";
          host = "1.1.1.1";
        };
        "Cloudflare_DNS_IPv6" = {
          name = "Cloudflare DNS IPv6";
          host = "2606:4700:4700::1111";
        };
        "Cloudflare_DNS_Secondary_IPv4" = {
          name = "Cloudflare DNS Secondary IPv4";
          host = "1.0.0.1";
        };
        "Cloudflare_DNS_Secondary_IPv6" = {
          name = "Cloudflare DNS Secondary IPv6";
          host = "2606:4700:4700::1001";
        };
      };
    };

    # Internet Connectivity
    "Internet" = {
      title = "Internet Connectivity Monitoring";
      menu = "Internet Connectivity";
      targets = {
        "Google_IPv4" = {
          name = "Google.com IPv4";
          host = "142.250.190.78";
        };
        "Google_IPv6" = {
          name = "Google.com IPv6";
          host = "2607:f8b0:4007:811::200e";
        };
        "Facebook_IPv6" = {
          name = "Facebook IPv6";
          host = "2a03:2880:f10d:183:face:b00c:0:25de";
        };
        "Yahoo_IPv6" = {
          name = "Yahoo IPv6";
          host = "2001:4998:24:120d::1:0";
        };
      };
    };

    # Add HTTP category and targets
    "HTTP" = {
      title = "HTTP Site Monitoring";
      menu = "HTTP Sites";
      targets = {
        "Google_HTTP" = {
          name = "Google HTTP";
          host = "google.com";
          probe = "Curl";
        };
        "IBM_HTTP" = {
          name = "IBM HTTP";
          host = "ibm.com";
          probe = "Curl";
        };
        "Yahoo_HTTP" = {
          name = "Yahoo HTTP";
          host = "yahoo.com";
          probe = "Curl";
        };
        "Facebook_HTTP" = {
          name = "Facebook HTTP";
          host = "facebook.com";
          probe = "Curl";
        };
      };
    };

    # Add DNS lookup testing
    "DNSLookup" = {
      title = "DNS Resolution Testing (dig queries)";
      menu = "DNS Resolution";
      targets = {
        "Google_DNS_Lookup" = {
          name = "Google DNS - google.com lookup";
          host = "8.8.8.8";
          probe = "DNS";
          lookup = "google.com";
        };
        "Cloudflare_DNS_Lookup" = {
          name = "Cloudflare DNS - google.com lookup";
          host = "1.1.1.1";
          probe = "DNS";
          lookup = "google.com";
        };
        "Local_DNS_Lookup" = {
          name = "Local DNS - google.com lookup";
          host = "::1";
          probe = "DNS";
          lookup = "google.com";
        };
      };
    };
  };

  generateTargetConfig = categoryName: category: ''
    + ${categoryName}
    menu = ${category.menu}
    title = ${category.title}

    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (targetName: target: ''
        ++ ${targetName}
        menu = ${target.name}
        title = ${target.name}${lib.optionalString (target ? probe) "\nprobe = ${target.probe}"}
        host = ${target.host}${lib.optionalString (target ? lookup) "\nlookup = ${target.lookup}"}
      '')
      category.targets)}'';

  # Generate the complete target configuration
  targetConfig = ''
    probe = FPing

    menu = Top
    title = Network Latency Grapher
    remark = Welcome to the SmokePing website of Siden Network Operations. \
             Here you will learn all about the latency of our network.

    ${lib.concatStringsSep "\n" (lib.mapAttrsToList generateTargetConfig targets)}'';

  # prometheusTargets = lib.flatten (lib.mapAttrsToList (
  #     categoryName: category:
  #       lib.mapAttrsToList (targetName: target: {
  #         name = "${categoryName}_${targetName}";
  #         host = target.host;
  #       })
  #       category.targets
  #   )
  #   targets);

  cfg = config.my.services.smokeping;
  internalport = 28008;
in
  with lib; {
    options.my.services.smokeping = {
      enable = mkEnableOption "";
      domain = mkOption {
        type = types.str;
        default = "ping.${config.networking.hostName}.unicycl.ing";
        description = "The domain smokeping is hosted on";
      };
    };

    config = mkIf cfg.enable {
      # Smokeping configuration for network monitoring
      # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/smokeping.nix
      services.smokeping = {
        enable = true;
        webService = false; # Disable automatic nginx configuration to avoid conflicts

        # Basic configuration
        # owner = "Network Operations";
        # ownerEmail = "ops@siden.io";
        # hostName = "smokeping.localhost";

        # Database configuration (5 minute intervals, 20 pings per step)
        # Using AVERAGE as the consolidation function (MEDIAN is not supported)
        databaseConfig = ''
          step     = 300
          pings    = 20
          # consfn mrhb steps total
          AVERAGE  0.5   1  1008
          AVERAGE  0.5  12  4320
              MIN  0.5  12  4320
              MAX  0.5  12  4320
          AVERAGE  0.5 144   720
              MAX  0.5 144   720
              MIN  0.5 144   720
        '';

        # Probe configuration for both IPv4 and IPv6
        # Modern fping handles IPv6 addresses automatically
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

        # Target configuration generated from data structure
        inherit targetConfig;

        # Alert configuration
        # alertConfig = ''
        #   to = root@localhost
        #   from = smokeping@localhost

        #   +someloss
        #   type = loss
        #   pattern = >0%,*12*,>0%,*12*,>0%
        #   comment = Loss of connectivity

        #   +highloss
        #   type = loss
        #   pattern = >50%,*12*,>50%,*12*,>50%
        #   comment = High loss of connectivity

        #   +highlatency
        #   type = rtt
        #   pattern = >100,*12*,>100,*12*,>100
        #   comment = High latency detected
        # '';

        # Presentation configuration
        presentationConfig = ''
          + charts
          menu = Charts
          title = The most interesting destinations
          ++ stddev
          sorter = StdDev(entries=>4)
          title = Top Standard Deviation
          menu = Std Deviation
          format = Standard Deviation %f
          ++ max
          sorter = Max(entries=>5)
          title = Top Max Roundtrip Time
          menu = by Max
          format = Max Roundtrip Time %f seconds
          ++ loss
          sorter = Loss(entries=>5)
          title = Top Packet Loss
          menu = Loss
          format = Packets Lost %f
          ++ median
          sorter = Median(entries=>5)
          title = Top Median Roundtrip Time
          menu = by Median
          format = Median RTT %f seconds
          + overview
          width = 600
          height = 50
          range = 10h
          + detail
          width = 600
          height = 200
          unison_tolerance = 2
          "Last 3 Hours"    3h
          "Last 30 Hours"   30h
          "Last 10 Days"    10d
          "Last 360 Days"   360d
        '';
      };

      networking.firewall.allowedTCPPorts = [80 443];

      # Ensure nginx can read cache/data for static file serving
      users.users.nginx.extraGroups = ["smokeping"];

      systemd.tmpfiles.rules = [
        "d /var/lib/smokeping/cache 0750 smokeping smokeping"
        "d /var/lib/smokeping/data 0750 smokeping smokeping"
        "Z /var/lib/smokeping 0750 smokeping smokeping"
      ];

      # Systemd security measures for smokeping
      systemd.slices.smokeping = {
        description = "Smokeping network monitoring slice";
        sliceConfig = {
          MemoryHigh = "200M";
          MemoryMax = "300M";
          CPUQuota = "20%";
          TasksMax = 200;
        };
      };

      # Enhanced smokeping service configuration with security measures
      # systemd-analyze security smokeping
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
          RestrictAddressFamilies = ["AF_INET" "AF_INET6"];

          # Additional security restrictions
          RemoveIPC = true; # Clean up IPC objects
          UMask = "0077"; # Restrict file permissions
          SystemCallFilter = ["@system-service" "~@privileged" "~@mount" "~@debug" "~@module" "~@reboot" "~@swap" "~@clock" "~@cpu-emulation" "~@obsolete"]; # Allow raw-io for IPv6 ping
          CapabilityBoundingSet = ["CAP_NET_RAW" "CAP_NET_BIND_SERVICE"]; # Only network capabilities needed
          ProtectProc = "default"; # Allow access to process info for DNS resolution
          ProcSubset = "all"; # Allow access to all process info
          ProtectHostname = true; # Prevent hostname changes
          ProtectClock = true; # Prevent clock changes

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
          SupplementaryGroups = ["smokeping"];

          # Restart policy
          Restart = "on-failure";
          RestartSec = "10s";

          # Nice priority (lower number = higher priority)
          Nice = 10;

          # Required by smokeping module
          ExecStart = "${config.services.smokeping.package}/bin/smokeping --config=/etc/smokeping.conf --nodaemon";
        };

        # Add curl package to the service environment
        path = [pkgs.curl pkgs.bind.dnsutils];
        environment = {
          # Ensure DNS resolution works
          NSS_WRAPPER_PASSWD = "/etc/passwd";
          NSS_WRAPPER_GROUP = "/etc/group";
          LD_LIBRARY_PATH = "${pkgs.curl}/lib";
        };
      };

      services.fcgiwrap = {
        enable = true;
        instances.smokeping = {
          process.user = cfg.user;
          process.group = cfg.user;
          socket = {inherit (config.services.nginx) user group;};
        };
      };

      services.nginx.virtualHosts."${cfg.domain}" = {
        forceSSL = false;

        listen = [
          {
            addr = "127.0.0.1";
            port = internalport;
          }
        ];

        root = "${pkgs.smokeping}/htdocs";
        extraConfig = ''
          index smokeping.fcgi;
          gzip off;
        '';

        locations."~ \\.fcgi$" = {
          extraConfig = ''
            fastcgi_intercept_errors on;
            include ${pkgs.nginx}/conf/fastcgi_params;
            fastcgi_param SCRIPT_FILENAME ${config.users.users.smokeping.home}/smokeping.fcgi;
            fastcgi_pass unix:/run/fcgiwrap.sock;
          '';
        };

        locations."/cache/" = {
          extraConfig = ''
            alias /var/lib/smokeping/cache/;
            gzip off;
          '';
        };
      };

      services.traefik.dynamicConfigOptions = {
        http = {
          routers = {
            smokeping = {
              rule = "Host(`${cfg.domain}`)";
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
                servers = [{url = "http://127.0.0.1:${internalport}";}];
              };
            };
          };
        };
      };
      # Also secure the prometheus smokeping exporter - DISABLED
      # systemd.services.prometheus-smokeping-exporter = {
      #   serviceConfig = {
      #     # Resource limits
      #     MemoryHigh = "512M";
      #     MemoryMax = "1G";
      #     CPUQuota = "25%";
      #
      #     # Security restrictions
      #     NoNewPrivileges = true;
      #     ProtectSystem = "strict";
      #     ProtectHome = true;
      #     ProtectKernelTunables = true;
      #     ProtectKernelModules = true;
      #     ProtectControlGroups = true;
      #     ProtectKernelLogs = true;
      #     PrivateDevices = true;
      #     RestrictRealtime = true;
      #     RestrictSUIDSGID = true;
      #     RestrictNamespaces = true;
      #     LockPersonality = true;
      #     MemoryDenyWriteExecute = true;
      #     RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
      #
      #     # Additional security restrictions
      #     RemoveIPC = true;  # Clean up IPC objects
      #     UMask = "0077";  # Restrict file permissions
      #     SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" "~@mount" "~@debug" "~@module" "~@reboot" "~@swap" "~@clock" "~@cpu-emulation" "~@obsolete" "~@raw-io" ];
      #     CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];  # Only binding capability needed
      #     ProtectProc = "invisible";  # Hide other processes
      #     ProcSubset = "pid";  # Only show own process info
      #     ProtectHostname = true;  # Prevent hostname changes
      #     ProtectClock = true;  # Prevent clock changes
      #
      #     # File system restrictions
      #     ReadWritePaths = [
      #       "/var/log"
      #       "/run"
      #     ];
      #     ReadOnlyPaths = [
      #       "/nix/store"
      #     ];
      #
      #     # Restart policy
      #     Restart = "on-failure";
      #     RestartSec = "10s";
      #
      #     # Nice priority
      #     Nice = 15;
      #   };
      # };
    };
  }
# Available Probes in NixOS Smokeping 2.8.2:
#
# Network/Connectivity Probes:
# - FPing: Standard ping using fping binary (IPv4/IPv6)
# - FPing6: Legacy IPv6 ping (deprecated, use FPing)
# - FPingContinuous: Continuous ping monitoring
# - RemoteFPing: Ping through remote host
# - TCPPing: TCP connection testing
# - TraceroutePing: Traceroute-based ping
#
# HTTP/Web Probes:
# - Curl: HTTP/HTTPS testing using curl binary
# - EchoPingHttp: HTTP echo ping
# - EchoPingHttps: HTTPS echo ping
# - WebProxyFilter: Web proxy testing
#
# DNS Probes:
# - DNS: DNS query testing
# - AnotherDNS: Alternative DNS testing
# - EchoPingDNS: DNS echo ping
# - CiscoRTTMonDNS: Cisco DNS monitoring
#
# SSH/Telnet Probes:
# - SSH: SSH connection testing
# - AnotherSSH: Alternative SSH testing
# - TelnetIOSPing: Cisco IOS telnet ping
# - TelnetJunOSPing: Juniper telnet ping
# - OpenSSHEOSPing: OpenSSH to Cisco IOS
# - OpenSSHJunOSPing: OpenSSH to Juniper
#
# Application Probes:
# - LDAP: LDAP connection testing
# - EchoPingLDAP: LDAP echo ping
# - Radius: RADIUS authentication testing
# - TacacsPlus: TACACS+ authentication testing
# - FTPtransfer: FTP file transfer testing
# - NFSping: NFS mount testing
# - Qstat: Quake server status
# - SipSak: SIP protocol testing
#
# Network Equipment Probes:
# - CiscoRTTMonEchoICMP: Cisco ICMP echo monitoring
# - CiscoRTTMonTcpConnect: Cisco TCP connection monitoring
# - DismanPing: DISMAN-PING-MIB SNMP ping
# - IOSPing: Cisco IOS ping
# - IRTT: In-band Round Trip Time
#
# Email Probes:
# - EchoPingSmtp: SMTP echo ping
# - SendEmail: Email sending test
#
# Other Probes:
# - EchoPingChargen: Chargen echo ping
# - EchoPingDiscard: Discard echo ping
# - EchoPingIcp: ICP echo ping
# - EchoPingWhois: Whois echo ping
# - EchoPingPlugin: Plugin-based echo ping
# - passwordchecker: Password checking
#
# Note: The HTTP probe is NOT available in NixOS smokeping 2.8.2.
# Use Curl probe for HTTP/HTTPS testing instead.


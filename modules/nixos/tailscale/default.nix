{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.services.tailscale;

  tsBoolFlag = flag: bool:
    if bool
    then "--${flag}"
    else "--${flag}=false";
in {
  options.my.services.tailscale = {
    enable = mkEnableOption "Enable Tailscale";
    runAsTSUser = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Run Tailscale as the Tailscale user
      '';
    };
    enableAutoUp = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable Tailscale autostart
      '';
    };
    advertiseExitNode = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Advertise this node as an exit node.
      '';
    };
    advertiseRoutes = {
      enable = mkEnableOption "Advertise routes";
      routes = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Advertise these routes.
        '';
      };
    };
    acceptRoutes = {
      enable = mkEnableOption "Accept routes";
      routes = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Accept these routes.
        '';
      };
    };
    advertiseTags = {
      enable = mkEnableOption "Advertise tags";
      tags = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Advertise these tags.
        '';
      };
    };
    enableWebUI = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable Tailscale Web UI on port 5252
      '';
    };

    web = {
      enable = mkEnableOption "Enable Tailscale Web UI";
      listenAddress = mkOption {
        type = types.str;
        default = "localhost:8088";
        description = ''
          Web UI Listen Address
        '';
      };
      runAsCgi = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Run as a CGI Script
        '';
      };
      pathPrefix = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          URL Path Prefix
        '';
      };
      readOnly = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Run the web UI in Read-only mode
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    age.secrets.tailscaleAuthKey =
      lib.optionalAttrs cfg.enableAutoUp
      ({
          file = ../../../secrets/tailscaleAuthKey.age;
        }
        // lib.optionalAttrs cfg.runAsTSUser {
          owner = "tailscale";
          group = "tailscale";
        });

    assertions = [
      {
        assertion = !((cfg.web.enable || cfg.enableWebUI) && cfg.web.enable == cfg.enableWebUI);
        message = "Tailscale Web UI cannot be enabled both thru the set flag and web config options. Pick only one";
      }
    ];

    networking = {
      firewall.trustedInterfaces = ["tailscale0"];
      # search = [
      #   "reindeer-porgy.ts.net"
      # ];
      # nameservers = [ "100.100.100.100" ];
    };

    services.tailscale =
      {
        enable = true;
        useRoutingFeatures = "both";

        extraUpFlags =
          ["--reset=true"]
          ++ (optional cfg.advertiseTags.enable "--advertise-tags=${concatStringsSep "," cfg.advertiseTags.tags}");

        extraSetFlags = [
          (tsBoolFlag "webclient" cfg.enableWebUI)
          (tsBoolFlag "advertise-exit-node" cfg.advertiseExitNode)
          "--advertise-routes=${concatStringsSep "," (optionals cfg.advertiseRoutes.enable (cfg.advertiseRoutes.routes))}"
        ];
      }
      // lib.optionalAttrs cfg.enableAutoUp {
        authKeyFile = config.age.secrets.tailscaleAuthKey.path;
      };

    users = mkIf cfg.runAsTSUser {
      users.tailscale = {
        isSystemUser = true;
        group = "tailscale";
        extraGroups = ["networkmanager" "resolvconf" "systemd-resolve" "systemd-network"];
      };
      groups.tailscale = {};
    };

    systemd.services = {
      tailscaled.serviceConfig = let
        caps = [
          "CAP_NET_ADMIN"
          "CAP_NET_BIND_SERVICE"
          "CAP_NET_RAW"
        ];
      in
        mkIf cfg.runAsTSUser {
          User = "tailscale";
          Group = "tailscale";
          CapabilityBoundingSet = mkForce caps;
          AmbientCapabilities = mkForce caps;
        };

      tailscaled-set.serviceConfig = mkIf cfg.runAsTSUser {
        User = "tailscale";
        Group = "tailscale";
      };

      tailscaled-autoconnect.serviceConfig = mkIf cfg.runAsTSUser {
        User = "tailscale";
        Group = "tailscale";
      };

      tailscale-web = mkIf cfg.web.enable {
        after = ["tailscaled.service"];
        wantedBy = ["multi-user.target"];
        wants = ["tailscaled.service"];
        serviceConfig = mkIf cfg.runAsTSUser {
          User = "tailscale";
          Group = "tailscale";
        };
        script = let
          baseFlag = ["--listen=${cfg.web.listenAddress}"];
          readOnly = optional cfg.web.readOnly "--readonly";
          cgiFlag = optional cfg.web.runAsCgi "--cgi";
          pathFlag = optional (cfg.web.pathPrefix != null) ["--path-prefix=${cfg.web.pathPrefix}"];
          flags = baseFlag ++ readOnly ++ cgiFlag ++ pathFlag;
        in ''
          ${config.services.tailscale.package}/bin/tailscale web ${escapeShellArgs flags}
        '';
      };
    };
  };
}

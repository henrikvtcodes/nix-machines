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
    age.secrets.tailscaleAuthKey.file = ../../../secrets/tailscaleAuthKey.age;

    assertions = [
      {
        assertion = !((cfg.web.enable || cfg.enableWebUI) && cfg.web.enable == cfg.enableWebUI);
        message = "Tailscale Web UI cannot be enabled both thru the set flag and web config options. Pick only one";
      }
    ];

    networking = {
      firewall.trustedInterfaces = ["tailscale0"];
      search = [
        "reindeer-porgy.ts.net"
        "unicycl.ing"
      ];
      # nameservers = [ "100.100.100.100" ];
    };

    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      authKeyFile = config.age.secrets.tailscaleAuthKey.path;
      extraUpFlags =
        ["--reset=true"]
        ++ (optional cfg.advertiseTags.enable "--advertise-tags=${concatStringsSep "," cfg.advertiseTags.tags}");

      extraSetFlags = [
        (tsBoolFlag "webclient" cfg.enableWebUI)
        (tsBoolFlag "advertise-exit-node" cfg.advertiseExitNode)
        "--advertise-routes=${concatStringsSep "," (optionals cfg.advertiseRoutes.enable (cfg.advertiseRoutes.routes))}"
      ];
    };

    systemd.services.tailscale-web = mkIf cfg.web.enable {
      after = ["tailscaled.service"];
      wantedBy = ["multi-user.target"];
      wants = ["tailscaled.service"];
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
}

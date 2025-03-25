{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.services.tailscale;

  formatUpOptions = {
    advertiseExitNode,
    advertiseTags,
    advertiseRoutes,
  }: let
    exitNodeFlag =
      if advertiseExitNode
      then ["--advertise-exit-node"]
      else [];
    tagFlags =
      if advertiseTags.enable && (length advertiseTags.tags > 0)
      then ["--advertise-tags=${concatStringsSep "," advertiseTags.tags}"]
      else [];
    routeFlags =
      if advertiseRoutes.enable && (length advertiseRoutes.routes > 0)
      then ["--advertise-routes=${concatStringsSep "," advertiseRoutes.routes}"]
      else [];
  in
    ["--reset=true"] ++ exitNodeFlag ++ tagFlags ++ routeFlags;
  # reset flag means that if any of the above settings change,
  # old routes/tags will not be accepted or advertised; as those settins will be reset

  formatSetOptions = {
    enableWebUI,
    advertiseExitNode,
    advertiseRoutes,
  }: let
    webUIFlag =
      if enableWebUI
      then ["--webclient=true"]
      else ["--webclient=false"];
    exitNodeFlag =
      if advertiseExitNode
      then ["--advertise-exit-node"]
      else ["--advertise-exit-node=false"];
    routeFlags =
      if advertiseRoutes.enable && (length advertiseRoutes.routes > 0)
      then ["--advertise-routes=${concatStringsSep "," advertiseRoutes.routes}"]
      else ["--advertise-routes="];
  in
    [] ++ webUIFlag ++ exitNodeFlag ++ routeFlags;
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
        type = types.string;
        default = "localhost:8088";
        description = ''
          Web UI Listen Address
        '';
      };
      cgi = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Run as a CGI Script
        '';
      };
      pathPrefix = mkOption {
        type = types.nullOr types.string;
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
      # extraUpFlags = formatUpOptions {
      #   # advertiseExitNode = cfg.advertiseExitNode;
      #   advertiseTags = cfg.advertiseTags;
      #   # advertiseRoutes = cfg.advertiseRoutes;
      # };
      extraSetFlags = formatSetOptions {
        enableWebUI = cfg.enableWebUI;
        advertiseExitNode = cfg.advertiseExitNode;
        advertiseRoutes = cfg.advertiseRoutes;
      };
    };

    systemd.services.tailscale-web = mkIf cfg.web.enable {
      after = ["tailscaled.service"];
      wantedBy = ["multi-user.target"];
      wants = ["tailscaled.service"];
      script = let
        nonNullFlags = ["--listen=${cfg.web.listenAddress}" "--cgi=${toString cfg.web.cgi}" "--readonly=${toString cfg.web.readOnly}"];
        pathFlag =
          if cfg.web.pathPrefix != null
          then ["--path-prefix=${cfg.web.pathPrefix}"]
          else [];
        flags = nonNullFlags ++ pathFlag;
      in ''
        ${config.services.tailscale.package}/bin/tailscale web ${escapeShellArgs flags}
      '';
    };
  };
}

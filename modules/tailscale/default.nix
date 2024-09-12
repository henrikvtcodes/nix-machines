{ config, lib, ... }:

with lib;
let
  cfg = config.svcs.tailscale;

  formatOptions =
    {
      advertiseExitNode,
      advertiseTags,
      advertiseRoutes,
    }:
    let
      exitNodeFlag = if advertiseExitNode then [ "--advertise-exit-node" ] else [ ];
      tagFlags =
        if advertiseTags.enable && (length advertiseTags.tags > 0) then
          [ "--advertise-tags=${concatStringsSep "," advertiseTags.tags}" ]
        else
          [ ];
      routeFlags =
        if advertiseRoutes.enable && (length advertiseRoutes.routes > 0) then
          [ "--advertise-routes=${concatStringsSep "," advertiseRoutes.routes}" ]
        else
          [ ];
    in
    [ "--reset=true" ] ++ exitNodeFlag ++ tagFlags ++ routeFlags;

in
{
  options.svcs.tailscale = {
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
        default = [ ];
        description = ''
          Advertise these routes.
        '';
      };
    };
    acceptRoutes = {
      enable = mkEnableOption "Accept routes";
      routes = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Accept these routes.
        '';
      };
    };
    advertiseTags = {
      enable = mkEnableOption "Advertise tags";
      tags = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Advertise these tags.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    age.secrets.tailscaleAuthKey.file = ../../secrets/tailscaleAuthKey.age;

    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      authKeyFile = config.age.secrets.tailscaleAuthKey.path;
      # extraUpFlags = [
      #   "--reset"
      #   # reset flag means that if any of the above settings change, 
      #   # old routes/tags will not be accepted or advertised; as those settins will be reset
      # ];
      extraUpFlags = formatOptions {
        advertiseExitNode = cfg.advertiseExitNode;
        advertiseTags = cfg.advertiseTags;
        advertiseRoutes = cfg.advertiseRoutes;
      };
      # extraSetFlags = formatOptions {
      #   advertiseExitNode = cfg.advertiseExitNode;
      #   advertiseTags = cfg.advertiseTags;
      #   advertiseRoutes = cfg.advertiseRoutes;
      # };
    };
  };
}

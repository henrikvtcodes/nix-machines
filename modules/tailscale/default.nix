{ config, lib, ... }:

with lib;
let
  cfg = config.svcs.tailscale;

  advertiseRoutes =
    if cfg.advertiseRoutes.enable then
      "--advertise-routes=${lib.concatStringsSep "," cfg.advertiseRoutes.routes}"
    else
      "--advertise-routes=\"\"";

  acceptRoutes =
    if cfg.acceptRoutes.enable then
      "--accept-routes=${lib.concatStringsSep "," cfg.acceptRoutes.routes}"
    else
      "--accept-routes=\"\"";

  advertiseTags =
    if cfg.advertiseTags.enable then
      "--advertise-tags=${lib.concatStringsSep "," cfg.advertiseTags.tags}"
    else
      "--advertise-tags=\"\"";

  setFlags = [
    advertiseRoutes
    acceptRoutes
    advertiseTags
  ] ++ optional cfg.advertiseExitNode "--advertise-exit-node";

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
      extraUpFlags = [
        "--reset"
        # reset flag means that if any of the above settings change, 
        # old routes/tags will not be accepted or advertised; as those settins will be reset
      ];
      extraSetFlags = setFlags;
    };
  };
}

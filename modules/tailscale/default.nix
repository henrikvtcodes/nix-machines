{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.svcs.tailscale;
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
    advertiseRoutes = mkOption {
      type = types.nullOr types.listOf types.str;
      default = null;
      description = ''
        Advertise these routes.
      '';
    };
  };

  config = mkIf cfg.enable {
    service.tailscale = {
      enable = true;
      authKeyFile = config.age.secrets.tailscaleAuthKey.path;
      extraUpFlags =
        [ "--hostname ${config.networking.hostName}" ]
        ++ optional cfg.advertiseExitNode [ "--advertise-exit-node" ]
        ++ optional cfg.advertiseRoutes [
          "--advertise-routes ${lib.concatStringsSep " " cfg.advertiseRoutes}"
        ];
    };
  };
}

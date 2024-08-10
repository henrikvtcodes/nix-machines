{ config, lib, ... }:

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
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Advertise these routes.
      '';
    };
  };

  config = mkIf cfg.enable {
    age.secrets.tailscaleAuthKey.file = ../../secrets/tailscaleAuthKey.age;

    services.tailscale = {
      enable = true;
      authKeyFile = config.age.secrets.tailscaleAuthKey.path;
      extraUpFlags =
        [ "--reset" ]
        ++ optional cfg.advertiseExitNode [ "--advertise-exit-node" ]
        ++ optional ((builtins.length cfg.advertiseRoutes) != 0) [
          "--advertise-routes ${lib.concatStringsSep " " cfg.advertiseRoutes}"
        ];
    };
  };
}

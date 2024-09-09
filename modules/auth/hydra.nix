{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.svcs.auth.hydra;
in
{

  options.svcs.auth.hydra = with lib; {
    enable = mkEnableOption { description = "Enable Ory Hydra Federation Server"; };
  };

  config = lib.mkIf cfg.enable { svcs.auth.enable = lib.mkForce true; };
}

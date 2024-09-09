{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.svcs.auth.keto = with lib; {
    enable = mkEnableOption { description = "Enable Ory Keto Permission Server"; };
  };

  config = lib.mkIf config.svcs.keto {
    svcs.auth.enable = lib.mkForce true;

  };
}

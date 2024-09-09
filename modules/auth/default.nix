{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.svcs.auth;
in
{
  imports = [
    ./kratos.nix
    ./hydra.nix
    ./keto.nix
  ];

  options.svcs.auth = with lib; {
    enable = mkEnableOption { description = "Enable Ory Identity and Access Management"; };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users.auth = {
        isSystemUser = true;
        home = "/var/lib/auth";
        description = "Auth service user";
        group = "auth";
        extraGroups = [ "docker" ];
      };
      groups.auth = {
        description = "Auth service group";
      };
    };
  };
}

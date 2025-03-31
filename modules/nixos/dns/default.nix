{
  inputs,
  pkgs,
  config,
  lib,
  system,
  ...
}: let
  cfg = config.my.services.dns;

  rootCorefile = builtins.readFile ./Corefile;
in {
  options.my.services.dns = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable custom CoreDNS DNS server";
    };
  };

  config = with lib;
    mkIf cfg.enable {
      services.coredns = {
        enable = true;
        package = inputs.coredns.packages.${system}.coredns;
        config = rootCorefile;
      };

      users = {
        users.coredns = {
          isSystemUser = true;
          group = "coredns";
        };
        groups.coredns = {};
      };

      systemd.services.coredns = let
        caps = [
          "CAP_NET_ADMIN"
          "CAP_NET_BIND_SERVICE"
        ];
      in {
        description = mkForce "Coredns DNS server";
        serviceConfig = {
          CapabilityBoundingSet = mkForce caps;
          AmbientCapabilities = mkForce caps;
          User = "coredns";
          Group = "coredns";
        };
      };
    };
}

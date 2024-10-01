{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.svcs.netcheck;

in
{
  options.svcs.netcheck = with lib; {
    enable = mkEnableOption "Enable netcheck";
    interface = mkOption {
      type = types.str;
      default = "eth0";
      description = "The network interface to check for DHCP";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.timers."netcheck" = {
      description = "Rebind DHCP interfaces and reload Tailscale if the network is down.";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "netcheck.service";
      };
    };

    systemd.services."netcheck" = {
      description = "Check internet access and rebind DHCP if necessary";
      script = ''
        ${pkgs.inetutils}/bin/ping -c 5 1.1.1.1 > /dev/null

        if [ $? -ne 0 ]; then
          ${pkgs.dhcpcd}/bin/dhcpcd --rebind ${cfg.interface}
          echo "DHCP rebound"
          systemctl restart tailscaled-autoconnect.service
          echo "Tailscale restarted"
        else
          echo "Internet is up"
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };
}

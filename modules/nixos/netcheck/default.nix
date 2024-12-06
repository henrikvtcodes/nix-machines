{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.svcs.netcheck;
in {
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
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "netcheck.service";
      };
    };

    systemd.services."netcheck" = {
      description = "Check internet access and rebind DHCP if necessary";
      script = ''
        ${pkgs.inetutils}/bin/ping -c 5 1.1.1.1

        echo "Checked internet access"

        if [ $? -ne 0 ]; then
          echo "Internet is down"
          systemctl restart dhcpcd.service
          ${pkgs.dhcpcd}/bin/dhcpcd --rebind ${cfg.interface}
          echo "DHCP rebound"
          systemctl restart tailscaled.service
          systemctl restart tailscaled-autoconnect.service
          echo "Tailscale restarted"

          sleep 120s
          echo "Rechecking internet access"

          ${pkgs.inetutils}/bin/ping -c 5 1.1.1.1

          if [ $? -ne 0 ]; then
            echo "Internet is still down, rebooting"

            shutdown -r now

          else
            echo "Internet is back up"
          fi

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

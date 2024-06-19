{ config, pkgs, ... }:
{

  environment.systemPackages = [ pkgs.dropbear ];

  services.openssh.enable = false;

  systemd.services.dropbear = {
    description = "Dropbear SSH server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.dropbear}/bin/dropbear -r ${config.system.build.openssh.hostKey} -p ${config.system.build.openssh.port}";
      Restart = "always";
      RestartSec = "10";
      StandardInput = "null";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };
}

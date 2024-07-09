# Credit to https://github.com/notthebee/nix-config/blob/main/modules/tailscale/default.nix
{ config, pkgs, ... }:
let
  hostname = config.networking.hostName;
in
{

  environment.systemPackages = with pkgs; [ tailscale ];

  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--hostname ${hostname}" ];
  };

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    after = [
      "network-pre.target"
      "tailscale.service"
    ];
    wants = [
      "network-pre.target"
      "tailscale.service"
    ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      LoadCredential = [ "TAILSCALE_AUTH_KEY_FILE:${config.age.secrets.tailscaleAuthKey.path}" ];
    };

    script = ''
      # wait for tailscaled to settle
      echo "Waiting for tailscale.service start completion ..." 
      sleep 5
      # (as of tailscale 1.4 this should no longer be necessary, but I find it still is)

      # check if already authenticated
      echo "Checking if already authenticated to Tailscale ..."
      status="$(${pkgs.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then  # do nothing
      	echo "Already authenticated to Tailscale, exiting."
        exit 0
      fi

      export TAILSCALE_AUTH_KEY=$(${pkgs.systemd}/bin/systemd-creds cat TAILSCALE_AUTH_KEY_FILE)
      ${pkgs.tailscale}/bin/tailscale up --auth-key "$TAILSCALE_AUTH_KEY" --hostname ${hostname} --
    '';
  };
}

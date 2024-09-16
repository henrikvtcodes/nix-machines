{ config, ... }:
{

  users = {
    users.woodpecker = {
      isSystemUser = true;
      group = "woodpecker";
      extraGroups = [
        "docker"
        "podman"
      ];
      createHome = true;
      home = "/etc/woodpecker";
      homeMode = "764";
    };
    groups.woodpecker = { };
  };

  # This sets up a woodpecker agent
  services.woodpecker-agents.agents."docker" = {
    enable = true;
    # We need this to talk to the podman socket
    extraGroups = [ "podman" ];
    environment = {
      WOODPECKER_SERVER = "barnegat:3006";
      WOODPECKER_MAX_WORKFLOWS = "4";
      DOCKER_HOST = "unix:///run/podman/podman.sock";
      WOODPECKER_BACKEND = "docker";
      WOODPECKER_HEALTHCHECK = "true";
      WOODPECKER_HEALTHCHECK_ADDR = "0.0.0.0:3007";
    };
    environmentFile = [ config.age.secrets.ciAgentSecrets.path ];
  };

  systemd.services."woodpecker-agent-docker".serviceConfig = {
    User = "woodpecker";
    Group = "woodpecker";
    WorkingDirectory = "/etc/woodpecker";
  };

  # systemd.services.ci-agent-config = {
  #   wantedBy = [ "woodpecker-agent-docker.service" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "woodpecker";
  #     Group = "woodpecker";
  #   };

  #   script = ''
  #     #!/bin/sh
  #     set -e
  #     mkdir -p /etc/woodpecker
  #     if [ ! -f /etc/woodpecker/agent.conf ]; then
  #       touch /etc/woodpecker/agent.conf
  #     fi
  #   '';
  # };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings = {
      dns_enabled = true;
    };
  };

  networking.firewall.interfaces."podman0" = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}

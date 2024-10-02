{ config, lib, ... }:
let
  cfg = config.ci-agent;
in
{

  options.ci-agent = with lib; {
    enable = mkEnableOption "ci-agent";
    serverAddress = mkOption {
      type = types.str;
      description = "Address of the woodpecker server";
    };
    healthcheckPort = mkOption {
      type = types.int;
      default = 3007;
      description = "Woodpecker Agent Healthcheck listen port";
    };
    environmentFiles = mkOption {
      type = types.listOf types.path;
      default = [ ];
      description = "Files containing secrets necessary for the agents";
    };
  };

  config = lib.mkIf cfg.enable {
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
        WOODPECKER_HEALTHCHECK_ADDR = "0.0.0.0:${toString cfg.healthcheckPort}";
      };
      environmentFile = [ config.age.secrets.ciAgentSecrets.path ];
    };

    systemd.services."woodpecker-agent-docker".serviceConfig = {
      User = "woodpecker";
      Group = "woodpecker";
      WorkingDirectory = "/etc/woodpecker";
    };

    virtualisation.podman = with lib; {
      dockerCompat = mkForce true;
      dockerSocket.enable = mkForce true;
      defaultNetwork.settings = {
        dns_enabled = mkForce true;
      };
    };

    networking.firewall.interfaces."podman0" = lib.mkForce {
      allowedUDPPorts = [ 53 ];
      allowedTCPPorts = [ 53 ];
    };
  };
}

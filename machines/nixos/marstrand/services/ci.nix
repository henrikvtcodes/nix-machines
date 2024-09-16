{ config, ... }:
{
  # This sets up a woodpecker agent
  services.woodpecker-agents.agents."marstrand" = {
    enable = true;
    # We need this to talk to the podman socket
    extraGroups = [ "podman" ];
    environment = {
      WOODPECKER_SERVER = "barnegat:9000";
      WOODPECKER_MAX_WORKFLOWS = "4";
      DOCKER_HOST = "unix:///run/podman/podman.sock";
      WOODPECKER_BACKEND = "docker";
    };
    environmentFile = [ config.age.secrets.ciAgentSecrets.path ];
  };
}

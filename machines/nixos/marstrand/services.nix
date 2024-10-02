{ config, ... }:
{
  imports = [ ./ci.nix ];

  svcs.ci-agent = {
    enable = true;
    serverAddress = "barnegat:3006";
    environmentFiles = [
      config.age.secrets.ciAgentSecrets.path
    ];
  };
}

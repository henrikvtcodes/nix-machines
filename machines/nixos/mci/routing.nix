{
  pkgs,
  config,
  ...
}: {
  environment.etc."bird/constants.conf".source = bird/constants.conf;
  environment.etc."bird/base.conf".source = bird/base.conf;

  services.bird = {
    enable = true;
    package = pkgs.bird2;
    config = builtins.readFile bird/bird.conf;
    checkConfig = false;
  };

  systemd.services.bird.reloadTriggers = [config.environment.etc."bird/bird.conf".source config.environment.etc."bird/base.conf".source config.environment.etc."bird/constants.conf".source];

  # Increase netlink buffers to stop bird from overflowing the netlink socket queue
  boot.kernel.sysctl = {
    "net.core.rmem_default" = 4194304;
    "net.core.rmem_max" = 4194304;
  };

  users.users.henrikvt.extraGroups = ["bird"];
}

{
  pkgs,
  lib,
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

  users.users.henrikvt.extraGroups = ["bird"];
}

{
  pkgs,
  lib,
  ...
}: {
  environment.etc."bird/filter_bgp.conf".source = bird/filter_bgp.conf;

  services.bird = {
    enable = true;
    package = pkgs.bird2;
    config = builtins.readFile bird/bird.conf;
    checkConfig = false;
  };

  users.users.henrikvt.extraGroups = ["bird"];
}

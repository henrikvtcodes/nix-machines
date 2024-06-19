{ config, pkgs, ... }:
{

  environment.systemPackages = [ pkgs.dropbear ];

}

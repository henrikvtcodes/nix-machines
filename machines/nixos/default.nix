{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{

  # Clean up nix store + old generations automatically
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;
  nix.optimise.dates = [ "weekly" ];

  security = {
    doas.enable = lib.mkDefault false;
    sudo = {
      enable = lib.mkDefault true;
      wheelNeedsPassword = lib.mkDefault true;
    };
  };

  environment.systemPackages = with pkgs; [
    iperf3
    rsync
    neofetch
  ];
}

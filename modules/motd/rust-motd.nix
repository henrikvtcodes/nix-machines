{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    rust-motd
    figlet
  ];

  programs.rust-motd = {
    enable = true;

    order = [
      "uptime"
      "filesystems"
    ];

    settings = {

      uptime.prefix = "Up: ";

      filesystems.root = "/";
    };
  };
}

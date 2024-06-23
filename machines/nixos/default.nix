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

  # Config sudo/doas commands
  security = {
    doas.enable = false;
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
    };
  };

  # Default networking/firewall settings
  networking = {
    enableIPv6 = true;
    useDHCP = true;
    firewall = {
      enable = true;
      allowPing = true;
    };
  };

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
  };

  # Hey, what does `with pkgs;` do?
  # It's a nixpkgs feature that allows you to use the pkgs variable without prefixing it with pkgs. 
  # ie, instead of `pkgs.git`, you can just write `git`
  environment.systemPackages = with pkgs; [
    # provides lspci, lsusb, lsblk
    pciutils
    usbutils
    util-linux

    # perf testing/viewing
    iperf3
    btop

    # dev tools
    git
    vim
    neovim

    # vanity
    neofetch
  ];
}

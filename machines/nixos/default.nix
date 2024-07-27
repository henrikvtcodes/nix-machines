{ pkgs, lib, ... }:
{

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    system-features = [ "recursive-nix" ];
  };

  config.system.hostname = lib.mkDefault "nixos";

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
      wheelNeedsPassword = lib.mkDefault true;
    };
  };

  # Default networking/firewall settings
  networking = {
    enableIPv6 = true;
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = lib.mkDefault true;
      allowPing = true;
    };
    wireless.enable = lib.mkDefault false;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # General Settings
  time.timeZone = lib.mkDefault "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Dont error on unfree (ie proprietary) packages
  nixpkgs.config.allowUnfree = true;

  # Hey, what does `with pkgs;` do?
  # It's a nixpkgs feature that allows you to use the pkgs variable without prefixing it with pkgs. 
  # ie, instead of `pkgs.git`, you can just write `git`
  environment.systemPackages = with pkgs; [
    # general system utilities
    pciutils
    usbutils
    util-linux
    dnsutils
    iotop
    iftop
    ethtool
    sysstat
    lm_sensors

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

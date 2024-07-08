{
  config,
  lib,
  pkgs,
  ...
}:
{
  networking = {
    enableIPv6 = true;
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = false;
      allowPing = true;
    };
    wireless.enable = false;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  time.timeZone = lib.mkDefault "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
    util-linux
    dnsutils
    iotop
    iftop
    ethtool
    sysstat
    lm_sensors

    iperf3
    btop

    git
    vim
  ];
}

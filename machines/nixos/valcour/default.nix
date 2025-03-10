{config, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-config.nix
    ./metrics
  ];

  networking.hostName = "valcour";
  networking.hostId = "5af035d8";

  boot.loader.systemd-boot.enable = true;
  # boot.loader.systemd-boot.bootCounting = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    firewall.enable = false;
    # dhcpcd.IPv6rs = true;
  };

  bootDisk = {
    enable = true;
    diskPath = "/dev/disk/by-id/nvme-KXG50ZNV256G_NVMe_TOSHIBA_256GB_687F729NFANP";
  };

  age.secrets = {
    valcourHealthcheckUrl.file = ../../../secrets/valcourHealthcheckUrl.age;
    # unpollerPassword = {
    #   owner = "unifi-poller";
    #   file = ../../../secrets/valcourUnpollerPassword.age;
    # };
  };

  # Healthcheck Ping
  my.services.betteruptime = {
    enable = true;
    healthcheckUrlFile = config.age.secrets.valcourHealthcheckUrl.path;
  };

  my.services.tailscale = {
    advertiseExitNode = true;
    advertiseRoutes = {
      enable = true;
      routes = ["10.205.16.212/32"];
    };
  };

  services.atftpd = {
    enable = true;
    # root = "/srv/tftp";
  };
  users = {
    users.henrikvt.extraGroups = [
      "tftp"
    ];
    users.tftp = {
      isSystemUser = true;
      group = "tftp";
      home = "/srv/tftp";
      createHome = true;
      homeMode = "777";
    };
    groups.tftp = {};
  };

  systemd.services.atftpd.serviceConfig = let
    caps = [
      "CAP_NET_ADMIN"
      "CAP_NET_BIND_SERVICE"
      "CAP_NET_RAW"
    ];
  in {
    User = "tftp";
    Group = "tftp";
    AmbientCapabilities = caps;
    CapabilityBoundingSet = caps;
  };

  my.services.netcheck = {
    enable = true;
    interface = "eno1";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11";
}

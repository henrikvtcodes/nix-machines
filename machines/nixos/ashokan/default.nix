{...}: {
  imports = [
    ./hardware-config.nix
  ];

  zramSwap.enable = true;
  networking = {
    hostName = "ashokan";
    domain = "unicycl.ing";
    firewall = {
      allowedTCPPorts = [
        80
        443
        69
        5201
      ];
      allowedUDPPorts = [53];
      enable = true;
    };
  };

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = false;
    device = "nodev";
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  services.fail2ban = {
    enable = true;
    ignoreIP = [
      # Whitelist RFC1918 addresses
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
      # CGNAT (ie Tailscale)
      "100.64.0.0/10"
      # UVM
      "132.198.0.0/16"
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    # Use nonstandard SSH port for public server
    ports = [22 69];
  };

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "23.11";
  # ======================== DO NOT CHANGE THIS ========================
}

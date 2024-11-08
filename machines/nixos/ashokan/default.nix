{...}: {
  imports = [
    ./hardware-config.nix
  ];

  zramSwap.enable = true;
  networking = {
    hostName = "ashokan";
    domain = "unicycl.ing";
  };

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

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
    # Use nonstandard SSH port for public server
    listenAddresses = [
      {
        addr = "0.0.0.0";
        port = 69;
      }
            {
        addr = "0.0.0.0";
        port = 22;
      }
    ];
  };

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "23.11";
  # ======================== DO NOT CHANGE THIS ========================
}

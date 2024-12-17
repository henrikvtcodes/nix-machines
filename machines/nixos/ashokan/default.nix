{lib, ...}: {
  imports = [
    ./hardware-config.nix
    ./services
  ];

  zramSwap.enable = true;
  networking = {
    hostName = "ashokan";
    hostId = "808b3324";
    domain = "unicycl.ing";
    firewall = {
      allowedTCPPorts = [
        80
        443
        22
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
      PermitRootLogin = lib.mkForce "yes";
      PasswordAuthentication = false;
    };
    # Use nonstandard SSH port for public server
    ports = [69 22];
  };

  # Secrets
  age.secrets = {
    cfDnsApiToken.file = ../../../secrets/cfDnsApiToken.age;
    mastodonSmtpPassword.file = ../../../secrets/mastodonSmtpPassword.age;
  };

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "23.11";
  # ======================== DO NOT CHANGE THIS ========================
}

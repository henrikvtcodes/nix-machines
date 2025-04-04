{...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-config.nix
    ./disk-config.nix
    ./networking.nix
    ./services
  ];

  networking = {
    hostName = "barnegat";
    domain = "unicycl.ing";
    hostId = "57e3eb57";
    useDHCP = false;
    dhcpcd.enable = false;
  };

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.loader.efi.canTouchEfiVariables = false;

  services.qemuGuest.enable = true;
  security.sudo.wheelNeedsPassword = false;

  services.prometheus.exporters.node.enable = true;

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
    ports = [22 69];
  };

  my.services.dns = {
    enable = true;
  };

  age.secrets = {
    cfDnsApiToken.file = ../../../secrets/cfDnsApiToken.age;
    ciSecrets.file = ../../../secrets/ciServerSecrets.age;
    ciAgentSecrets.file = ../../../secrets/ciAgentSecrets.age;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05";
}

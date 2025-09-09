{config, ...}: {
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
        69
        80
        443
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
    # Use nonstandard SSH port for public server
    ports = [69 22];
  };

  # Secrets
  age.secrets = let
    secretsDir = ../../../secrets;
    chownPodman = secret: {
      file = "${secretsDir}/${secret}";
      group = "podman";
      mode = "0400";
    };
  in {
    netboxSecretKey = {
      file = "${secretsDir}/netboxSecretKey.age";
      owner = "netbox";
      group = "netbox";
    };

    netbirdDSEKey = {
      file = "${secretsDir}/netbirdDSEKey";
      owner = "netbird";
      group = "netbird";
    };

    mealieCredentials = {
      file = "${secretsDir}/mealieCredentials.age";
    };
    cfDnsApiToken.file = "${secretsDir}/cfDnsApiToken.age";
    netbirdTurnUserPassword = {
      file = "${secretsDir}/netbirdTurnUserPassword.age";
      owner = "turnserver";
    };
    mastodonSmtpPassword = chownPodman "mastodonSmtpPassword.age";
    mastodonVapidKeys = chownPodman "mastodonVapidEnvVars.age";
    mastodonSecretKeyBase = chownPodman "mastodonSecretKeyBase.age";
    mastodonOtpSecret = chownPodman "mastodonOtpSecret.age";
    mastodonAREncryptionEnvVars = chownPodman "mastodonAREncryptionEnvVars.age";
    mastodonJortageSecretEnvVars = chownPodman "jortageSecretEnvVars.age";
  };

  security.acme.defaults = {
    dnsPropagationCheck = true;
    dnsProvider = "cloudflare";
    dnsResolver = "8.8.8.8:53";
    environmentFile = config.age.secrets.cfDnsApiToken.path;
    email = "acme@unicycl.ing";
  };
  security.acme.acceptTerms = true;

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "23.11";
  # ======================== DO NOT CHANGE THIS ========================
}

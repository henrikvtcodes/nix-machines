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
    ports = [69];
  };

  # Secrets
  age.secrets = let
    secretsDir = ../../../secrets;
  in {
    cfDnsApiToken.file = "${secretsDir}/cfDnsApiToken.age";
    mastodonSmtpPassword.file = "${secretsDir}/mastodonSmtpPassword.age";
    mastodonVapidKeys.file = "${secretsDir}/mastodonVapidKeys.age";
    mastodonSecretKeyBase.file = "${secretsDir}/mastodonSecretKeyBase.age";
    mastodonOtpSecret.file = "${secretsDir}/mastodonOtpSecret.age";
    mastodonAREncryptionEnvVars.file = "${secretsDir}/mastodonAREncryptionEnvVars.age";
  };

  svcs.traefik = {
    enable = true;
    environmentFiles = [config.age.secrets.cfDnsApiToken.path];
  };

  svcs.mastodon = {
    enable = true;
    configureTraefik = true;
    secretKeyBaseEnvFile = config.age.secrets.mastodonSecretKeyBase.path;
    otpSecretEnvFile = config.age.secrets.mastodonOtpSecret.path;
    vapidKeysEnvFile = config.age.secrets.mastodonVapidKeys.path;
    smtpPasswordEnvFile = config.age.secrets.mastodonSmtpPassword.path;
    activeRecordEncryptionEnvFile = config.age.secrets.mastodonAREncryptionEnvVars.path;
  };

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "23.11";
  # ======================== DO NOT CHANGE THIS ========================
}

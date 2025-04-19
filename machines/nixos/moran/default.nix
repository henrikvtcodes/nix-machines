{
  lib,
  pkgs,
  unstable,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-config.nix
    ./wmde.nix
  ];

  # boot.loader.systemd-boot.enable = true;
  boot.loader = {
    efi.canTouchEfiVariables = true;

    # efi.efiSysMountPoint = "/boot/efi";
    #systemd-boot.enable = true;
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = false;
      useOSProber = true;
    };
  };

  catppuccin.enable = true;
  catppuccin.flavor = "mocha";

  networking.networkmanager.enable = true;

  networking.hostName = "moran";
  networking.hostId = "e5da046e";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  nix = {
    settings = {
      extra-substituters = ["https://hyprland.cachix.org"];
      extra-trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with unstable; [
      nerd-fonts.symbols-only
      nerd-fonts.caskaydia-mono
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];
  };

  services.openssh.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.package = pkgs.kdePackages.sddm;
  # services.desktopManager.plasma6.enable = true;

  services.fwupd.enable = true;

  programs.firefox.enable = true;

  home.henrikvt = {
    ghostty = true;
    extraModules = [
      ./home
    ];
  };

  users.users.henrikvt.packages = with pkgs; [fprintd];

  security.sudo.wheelNeedsPassword = true;

  time.hardwareClockInLocalTime = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = ["yourUsernameHere"];
  };

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  hardware.graphics.enable = true;

  services = {
    printing.enable = true; # Cups
    pcscd.enable = true; # Smart card (Yubikey) daemon

    # Sound
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    udev.packages = [pkgs.yubikey-personalization];
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  environment.systemPackages = with pkgs; [batmon vscode-fhs];

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  networking.networkmanager.wifi.powersave = true;

  services = {
    usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };
  };

  nixpkgs.overlays = with inputs; [
    nur.overlays.default
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11";
}

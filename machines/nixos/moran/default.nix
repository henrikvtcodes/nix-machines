{
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
    efi.canTouchEfiVariables = false;
    grub = {
      enable = true;
      copyKernels = true;
      # device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
      useOSProber = true;
      zfsSupport = true;
      mirroredBoots = [
        {
          devices = ["nodev"];
          path = "/boot";
        }
      ];
    };
  };

  catppuccin.enable = true;
  catppuccin.flavor = "mocha";

  networking = {
    networkmanager = {
      enable = true;
      wifi = {
        powersave = true;
        #backend = "iwd";
        backend = "wpa_supplicant";
        macAddress = "permanent";
      };
    };
    useDHCP = false;
    dhcpcd.enable = false;
    wireless.enable = false;
    wireless.iwd.enable = false;
    useNetworkd = true;
  };
  systemd.network = {
    enable = true;
    wait-online.enable = false;
  };

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

  my.services.tailscale = {
    enableAutoUp = false;
    acceptRoutes = true;
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

  users.users.henrikvt.extraGroups = ["video" "bird"];

  services.openssh.enable = true;

  services.fwupd = {
    enable = true;
    package =
      (import (builtins.fetchTarball {
          url = "https://github.com/NixOS/nixpkgs/archive/bb2009ca185d97813e75736c2b8d1d8bb81bde05.tar.gz";
          sha256 = "sha256:003qcrsq5g5lggfrpq31gcvj82lb065xvr7bpfa8ddsw8x4dnysk";
        }) {
          inherit (pkgs) system;
        })
      .fwupd;
  };

  programs.firefox.enable = true;

  home.henrikvt = {
    enable = true;
    ghostty = true;
    client = true;
    extraModules = [
      ./home
    ];
  };

  programs.nh = {
    enable = true;
    flake = "/home/henrikvt/Desktop/code/projects/nixmachines";
  };

  environment.shellAliases = {
    rebuild = "${pkgs.nh}/bin/nh os switch && omz reload";
    reload = "omz reload";
  };

  security.sudo.wheelNeedsPassword = true;

  time.hardwareClockInLocalTime = true; # Windows compatibility

  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      # Certain features, including CLI integration and system authentication support,
      # require enabling PolKit integration on some desktop environments (e.g. Plasma).
      polkitPolicyOwners = ["henrikvt"];
    };
    hyprlock.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [thunar-archive-plugin thunar-volman];
    };
  };

  services.pulseaudio.enable = false;
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
    spotifyd = {
      enable = true;
    };
  };

  # FIXME Don't forget to create an authorization mapping file for your user (https://nixos.wiki/wiki/Yubikey#pam_u2f)
  security.pam.u2f = {
    enable = true;
    settings.cue = true;
    control = "sufficient";
  };

  security.pam.services = {
    greetd.u2fAuth = true;
    sudo.u2fAuth = true;
    hyprlock.u2fAuth = true;
  };

  # USB Automounting
  services.gvfs.enable = true;

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    batmon
    keepassxc
    vscode-fhs
    yubikey-manager
    avizo
    playerctl
    blueman
    uutils-coreutils-noprefix
    yubioath-flutter
    libreoffice-qt-fresh
  ];

  powerManagement = {
    enable = true;
  };

  services = {
    usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };
    hypridle.enable = true;
    fprintd.enable = true;
  };

  services.logind = {
    powerKey = "lock";
    powerKeyLongPress = "poweroff";
    suspendKey = "ignore";
    suspendKeyLongPress = "poweroff";
    hibernateKey = "ignore";
    hibernateKeyLongPress = "poweroff";
    rebootKey = "ignore";
    rebootKeyLongPress = "poweroff";
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

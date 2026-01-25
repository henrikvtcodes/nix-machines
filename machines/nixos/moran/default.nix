{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-config.nix
    ./wmde.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = false;
    grub = {
      enable = true;
      copyKernels = true;
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

  catppuccin = {
    enable = true;
    flavor = "mocha";
  };

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

  age.secrets = let
    secretsDir = ../../../secrets;
  in {
    ziplineToken = {
      file = "${secretsDir}/ziplineToken.age";
      owner = "henrikvt";
      group = "henrikvt";
    };
  };

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
    packages = with pkgs; [
      nerd-fonts.symbols-only
      nerd-fonts.caskaydia-mono
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];
  };

  users.users.henrikvt.extraGroups = ["video" "bird"];

  home.henrikvt = {
    enable = true;
    ghostty = false;
    client = true;
    extraModules = [
      ./home
    ];
  };

  environment = {
    shellAliases = {
      rebuild = "${pkgs.nh}/bin/nh os switch && omz reload";
      reload = "omz reload";
    };

    systemPackages = with pkgs; [
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
    firefox.enable = true;
    nh = {
      enable = true;
      flake = "/home/henrikvt/Desktop/code/projects/nixmachines";
    };
    dconf.enable = true;
  };

  services = {
    printing.enable = true; # Cups
    pcscd.enable = true; # Smart card (Yubikey) daemon
    gvfs.enable = true; # USB Automounting

    # Sound
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    pulseaudio.enable = false;

    udev.packages = [pkgs.yubikey-personalization];
    spotifyd = {
      enable = true;
    };
    openssh.enable = true;

    # Firmware Update Daemon
    fwupd = {
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

    # USB multiplexing for iOS (can enable tethering)
    usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };
    # Lock screen
    hypridle.enable = true;
    # Fingerprints
    fprintd.enable = true;

    logind.settings.Login = {
      HandlePowerKey = "lock";
      HandlePowerKeyLongPress = "poweroff";
      # HandleSuspendKey = "ignore";
      # HandleSuspendKeyLongPress = "poweroff";
      # HandleHibernateKey = "ignore";
      # HandleHibernateKeyLongPress = "poweroff";
      # HandleRebootKey = "ignore";
      # HandleRebootKeyLongPress = "poweroff";
    };
  };

  security = {
    # Used by pipewire for permission escalation
    rtkit.enable = true;
    pam = {
      # FIXME Don't forget to create an authorization mapping file for your user (https://nixos.wiki/wiki/Yubikey#pam_u2f)
      u2f = {
        enable = true;
        settings.cue = true;
        control = "sufficient";
      };
      services = {
        greetd.u2fAuth = true;
        sudo.u2fAuth = true;
        hyprlock.u2fAuth = true;
      };
    };
  };

  hardware = {
    graphics.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  powerManagement = {
    enable = true;
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

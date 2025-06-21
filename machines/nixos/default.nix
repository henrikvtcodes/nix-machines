{
  pkgs,
  lib,
  system,
  config,
  ...
}: {
  imports = [../../modules/nixos ../../home/henrikvt];

  # Clean up nix store + old generations automatically
  nix = {
    #gc = {
    #  automatic = true;
    #  dates = "weekly";
    #  options = "--delete-older-than 30d";
    #};
    optimise = {
      automatic = true;
      dates = ["weekly"];
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "recursive-nix"
      ];
      system-features = ["recursive-nix"];
      trusted-users = ["root" "@wheel"];
      extra-substituters = ["https://nix-community.cachix.org"];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 2 --keep-since 14d";
    };
  };

  # Config sudo/doas commands
  security = {
    doas.enable = false;
    sudo = {
      enable = true;
      wheelNeedsPassword = lib.mkDefault false;
    };
  };

  # Agenix
  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
    "/etc/ssh/ssh_host_rsa_key"
  ];

  # Default networking/firewall settings
  networking = {
    enableIPv6 = true;
    hostName = lib.mkDefault "nixos";
    useDHCP = lib.mkDefault true;
    tempAddresses = lib.mkDefault "disabled";
    networkmanager.enable = lib.mkDefault false;
    dhcpcd.persistent = lib.mkDefault true;
    firewall = {
      enable = lib.mkDefault false;
      allowPing = true;
    };
    wireless.enable = lib.mkDefault false;
    nameservers = lib.mkDefault [
      "9.9.9.10"
      "149.112.112.10"
      "2620:fe::10"
      "2620:fe::fe:10"
    ];
  };
  my.services.tailscale = {
    enable = lib.mkDefault true;
    web.enable = lib.mkDefault true;
    web.listenAddress = lib.mkDefault "[::]:5252"; # Works on v4 & v6 bc the kernel opts below forward v4 to v6
  };

  # https://www.kernel.org/doc/html/latest/networking/ip-sysctl.html
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.accept_ra" = 0;
  };

  boot.growPartition = lib.mkDefault true;

  # Enable SSH server
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.prometheus = {
    listenAddress = lib.mkDefault "[::]";
    exporters.node = {
      # Enable node-exporter by default
      enable = lib.mkDefault true;
      enabledCollectors = lib.mkDefault [
        "zfs"
        "systemd"
      ];
    };
  };

  services.iperf3 = {
    enable = true;
    openFirewall = true;
    port = 42052;
  };

  # Enable containers
  virtualisation = {
    podman = {
      enable = lib.mkDefault true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };
    oci-containers.backend = "podman";
  };
  networking.firewall.interfaces.podman0.allowedUDPPorts = [53];

  # General Settings
  time.timeZone = lib.mkDefault "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Clean /tmp on reboot
  boot.tmp.cleanOnBoot = true;

  # Dont error on unfree (ie proprietary) packages
  nixpkgs.config.allowUnfree = true;

  # Enable henrikvt home config and other options
  home.henrikvt.enable = lib.mkDefault true;
  users.henrikvt.enableNixosSpecific = lib.mkDefault true;
  users.henrikvt.enablePasswordFile = lib.mkDefault true;

  # Hey, what does `with pkgs;` do?
  # It's a nixpkgs feature that allows you to use the pkgs variable without prefixing it with pkgs.
  # ie, instead of `pkgs.git`, you can just write `git`
  environment.systemPackages = with pkgs; [
    # general system utilities
    pciutils # setpci lspci pcilmr
    usbutils # usbhid-dump lsusb lsusb.py usb-devices
    util-linux # nsenter isosize utmpdump wall fincore prlimit namei uuidparse blkpr write swapoff mount rename logger
    # ipcmk taskset swapon blockdev umount swaplabel scriptreplay resizepart script findfs mountpoint fstrim ipcs sulogin
    # mesg wipefs fsfreeze ldattach fdisk readprofile setpriv rev login colrm choom setterm cal lastb kill zramctl scriptlive
    # addpart lsblk linux32 irqtop nologin ctrlaltdel lsmem waitpid getopt lscpu col chmem partx mkfs.minix fsck.minix
    # pivot_root setarch column chrt eject lslocks lslogins blkzone linux64 x86_64 fallocate pipesz fsck whereis rfkill
    # last unshare renice ionice chsh cfdisk lsirq more losetup hexdump switch_root runuser uclampset wdctl flock look
    # hardlink fadvise blkid hwclock delpart chcpu lsns mkswap agetty chfn rtcwake mkfs sfdisk lsfd ipcrm mkfs.bfs colcrt
    # mkfs.cramfs lsipc fsck.cramfs i386 setsid uname26 blkdiscard uuidd ul dmesg uuidgen findmnt mcookie

    iotop # iotop
    iftop # iftop
    ethtool # ethtool
    sysstat # iostat tapestat mpstat sar sadf pidstat cifsiostat
    lm_sensors # sensors pwmconfig sensors-conf-convert isaset fancontrol sensors-detect isadump
    smartmontools # smartd smartctl
    dhcpcd # dhcpcd
    inetutils # logger rlogin rcp tftp ping talk ping6 rexec ifconfig dnsdomainname ftp whois rsh hostname telnet traceroute
    q # dns client `q`
    dig # arpaname ddns-confgen delv dig dnssec-cds dnssec-dsfromkey dnssec-importkey dnssec-keyfromlabel dnssec-keygen
    # dnssec-revoke dnssec-settime dnssec-signzone dnssec-verify host mdig named named-checkconf named-checkzone
    # named-compilezone named-journalprint named-rrchecker nsec3hash nslookup nsupdate rndc rndc-confgen tsig-keygen
    gdu
    diskus

    doggo
    # perf testing/viewing
    iperf3
    btop
    speedtest-cli # speedtest speedtest-cli

    # dev tools
    git
    vim

    # other
    bsdgames

    diskus

    attic-client
  ];
}

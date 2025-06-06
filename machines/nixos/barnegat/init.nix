# This file is used to initialize this specific machine. VPS' are weird.
{
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
    ./disk-config.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev"; # or "nodev" for efi only
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "barnegat"; # Define your hostname.

  networking.interfaces.ens3.ipv4.addresses = [
    {
      address = "162.120.71.172";
      prefixLength = 24;
    }
  ];
  networking.interfaces.ens3.ipv6.addresses = [
    {
      address = "2a0a:8dc0:2000:a5::2";
      prefixLength = 126;
    }
  ];

  networking.defaultGateway = {
    address = "162.120.71.1";
    interface = "ens3";
  };
  networking.defaultGateway6 = {
    address = "2a0a:8dc0:2000:a5::1";
    interface = "ens3";
  };

  networking.nameservers = [
    "9.9.9.10"
    "149.112.112.10"
    "2620:fe::10"
    "2620:fe::fe:10"
  ];

  users.users.henrikvt = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINimhbJZN+MLdXbtk3Mrb5dca7P+LKy399OqqYZ122Ml"
    ];
  };

  security = {
    doas.enable = false;
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };

  # Dont error on unfree (ie proprietary) packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # general system utilities
    # pciutils # setpci lspci pcilmr
    # usbutils # usbhid-dump lsusb lsusb.py usb-devices
    # util-linux # nsenter isosize utmpdump wall fincore prlimit namei uuidparse blkpr write swapoff mount rename logger ipcmk taskset swapon blockdev umount swaplabel scriptreplay resizepart script findfs mountpoint fstrim ipcs sulogin mesg wipefs fsfreeze ldattach fdisk readprofile setpriv rev login colrm choom setterm cal lastb kill zramctl scriptlive addpart lsblk linux32 irqtop nologin ctrlaltdel lsmem waitpid getopt lscpu col chmem partx mkfs.minix fsck.minix pivot_root setarch column chrt eject lslocks lslogins blkzone linux64 x86_64 fallocate pipesz fsck whereis rfkill last unshare renice ionice chsh cfdisk lsirq more losetup hexdump switch_root runuser uclampset wdctl flock look hardlink fadvise blkid hwclock delpart chcpu lsns mkswap agetty chfn rtcwake mkfs sfdisk lsfd ipcrm mkfs.bfs colcrt mkfs.cramfs lsipc fsck.cramfs i386 setsid uname26 blkdiscard uuidd ul dmesg uuidgen findmnt mcookie
    # iotop # iotop
    # iftop # iftop
    # ethtool # ethtool
    # sysstat # iostat tapestat mpstat sar sadf pidstat cifsiostat
    # lm_sensors # sensors pwmconfig sensors-conf-convert isaset fancontrol sensors-detect isadump
    # smartmontools # smartd smartctl
    # dhcpcd # dhcpcd

    # perf testing/viewing
    # iperf3
    btop

    # dev tools
    git
    vim
    zfs
  ];

  networking = {
    enableIPv6 = true;
    useDHCP = lib.mkDefault false;
    firewall = {
      enable = false;
      allowPing = true;
    };
    wireless.enable = false;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}

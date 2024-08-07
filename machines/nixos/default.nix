{ pkgs, lib, ... }:
{

  imports = [
    ../../modules/tailscale
    ../../modules/boot-disk
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    system-features = [ "recursive-nix" ];
  };

  # Clean up nix store + old generations automatically
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };

  # Config sudo/doas commands
  security = {
    doas.enable = false;
    sudo = {
      enable = true;
      wheelNeedsPassword = lib.mkDefault true;
    };
  };

  # Default networking/firewall settings
  networking = {
    enableIPv6 = true;
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = lib.mkDefault true;
      allowPing = true;
    };
    wireless.enable = lib.mkDefault false;
  };
  networking.hostName = lib.mkDefault "nixos";
  svcs.tailscale.enable = lib.mkDefault true;

  # Enable SSH server
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # General Settings
  time.timeZone = lib.mkDefault "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Dont error on unfree (ie proprietary) packages
  nixpkgs.config.allowUnfree = true;

  # Hey, what does `with pkgs;` do?
  # It's a nixpkgs feature that allows you to use the pkgs variable without prefixing it with pkgs. 
  # ie, instead of `pkgs.git`, you can just write `git`
  environment.systemPackages = with pkgs; [
    # general system utilities
    pciutils # setpci lspci pcilmr
    usbutils # usbhid-dump lsusb lsusb.py usb-devices
    util-linux # nsenter isosize utmpdump wall fincore prlimit namei uuidparse blkpr write swapoff mount rename logger ipcmk taskset swapon blockdev umount swaplabel scriptreplay resizepart script findfs mountpoint fstrim ipcs sulogin mesg wipefs fsfreeze ldattach fdisk readprofile setpriv rev login colrm choom setterm cal lastb kill zramctl scriptlive addpart lsblk linux32 irqtop nologin ctrlaltdel lsmem waitpid getopt lscpu col chmem partx mkfs.minix fsck.minix pivot_root setarch column chrt eject lslocks lslogins blkzone linux64 x86_64 fallocate pipesz fsck whereis rfkill last unshare renice ionice chsh cfdisk lsirq more losetup hexdump switch_root runuser uclampset wdctl flock look hardlink fadvise blkid hwclock delpart chcpu lsns mkswap agetty chfn rtcwake mkfs sfdisk lsfd ipcrm mkfs.bfs colcrt mkfs.cramfs lsipc fsck.cramfs i386 setsid uname26 blkdiscard uuidd ul dmesg uuidgen findmnt mcookie
    iotop # iotop
    iftop # iftop
    ethtool # ethtool
    sysstat # iostat tapestat mpstat sar sadf pidstat cifsiostat
    lm_sensors # sensors pwmconfig sensors-conf-convert isaset fancontrol sensors-detect isadump
    smartmontools # smartd smartctl
    dhcpcd # dhcpcd

    # perf testing/viewing
    iperf3
    btop

    # dev tools
    git
    vim
    neovim

    # vanity
    neofetch
  ];
}

{lib, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-config.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  networking.hostName = "penikese";
  networking.hostId = "e55b3488";

  services.qemuGuest.enable = true;

  users.henrikvt.enablePasswordFile = false;

  networking = {
    dhcpcd.IPv6rs = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11";
}

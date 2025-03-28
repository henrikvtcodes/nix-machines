{
  pkgs,
  modulesPath,
  system,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  nixpkgs.hostPlatform = system;

  # This is a workaround for the fact that the default image does not
  # include the `nix` command.
  environment.systemPackages = with pkgs; [
    git
    parted
    disko
  ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "recursive-nix"
      ];
      system-features = ["recursive-nix"];
      trusted-users = ["root" "@wheel" "nixos"];
    };
  };

  users.users.nixos = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINimhbJZN+MLdXbtk3Mrb5dca7P+LKy399OqqYZ122Ml"
    ];
  };

  networking.nameservers = ["1.0.0.1" "1.1.1.1" "2606:4700:4700::1111" "2606:4700:4700::1001"];
  networking.networkmanager.enable = true;
}

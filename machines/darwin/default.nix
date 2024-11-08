{lib}: {
  # Clean up nix store + old generations automatically
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
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
    };
  };

  # Force the nix daemon to run
  services.nix-daemon.enable = lib.mkForce true;
}

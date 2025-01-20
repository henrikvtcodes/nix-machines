{
  inputs,
  config,
  lib,
  ...
}: let
  homeCfg = config.home.henrikvt;
in {
  options.home.henrikvt = with lib; {
    enable = mkEnableOption "Enable henrikvt's home configuration";
    ghDash = mkEnableOption "Enable GitHub TUI Dashboard"; # Github TUI dashboard doesn't play nice on all systems
    ghostty = mkEnableOption "Enable Ghostty Config";
    prompt = {
      dev = mkOption {
        type = types.bool;
        default = false;
        description = "Show git statuses";
      };
      server = mkOption {
        type = types.bool;
        default = false;
        description = "Show hostname";
      };
    };
  };

  config = lib.mkIf homeCfg.enable {
    # Home Manager
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs;
        inherit homeCfg;
      };
      backupFileExtension = "hmbak";
      users.henrikvt = import ./home.nix;
    };
  };
}

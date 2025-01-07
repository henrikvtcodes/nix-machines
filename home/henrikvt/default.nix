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

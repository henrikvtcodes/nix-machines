{
  description = "nix configuration for my servers + other stuff";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-24.05";
    };

    # Core tools: home manager, secrets, disk partitioning, deployment
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://docs.hercules-ci.com/arion/
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      deploy-rs,
      agenix,
      ...
    }@inputs:
    let
      vars = import "./vars.nix";
    in
    {

      nixosConfigurations = {
        svalbard = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs vars;
          };
          modules = [
            # Machine config
            ./machines/nixos
            ./machines/nixos/svalbard

            agenix.nixosModules.default
          ];
        };
      };

      deploy.nodes = {
        svalbard = {
          hostName = "svalbard";
          profiles.system = {
            remoteBuild = true;
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.svalbard;
          };
        };
      };
    };
}

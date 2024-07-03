{
  description = "nix configuration for my servers + other stuff";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/release-24.05";
    };

    systems.url = "github:nix-systems/default";

    # Core tools: home manager, secrets, disk partitioning, deployment
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      # agenix-compatible but in rust, for stability
      url = "github:yaxitech/ragenix";
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

    impermanence = {
      url = "github:nix-community/impermanence";
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
      home-manager,
      agenix,
      systems,
      disko,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib // home-manager.lib;

      forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});

      pkgsFor = lib.genAttrs (import systems) (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );

      vars = import "./vars.nix";

    in
    {
      inherit lib;

      devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs; });

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
            disko.nixosModules.disko
            agenix.nixosModules.default

            # Services config

            # User config
            ./users
            home-manager.nixosModules.home-manager.default
            {
              home-manager = {
                users.henrikvt = import ./users/henrikvt;
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit inputs vars;
                };
              };
            }
          ];
        };

        doghouse = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs vars;
          };
          modules = [
            # Machine config
            ./machines/nixos
            ./machines/nixos/doghouse
            disko.nixosModules.disko
            agenix.nixosModules.default

            # Services config

            # User config
            ./users
            home-manager.nixosModules.home-manager.default
            {
              home-manager = {
                users.henrikvt = import ./users/henrikvt;
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit inputs vars;
                };
              };
            }
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
        doghouse = {
          hostName = "doghouse";
          profiles.system = {
            remoteBuild = true;
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.doghouse;
          };
        };
      };

      # Enables nix flake check to ensure that the deploy-rs config is correct
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}

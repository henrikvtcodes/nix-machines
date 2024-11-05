{
  description = "nix configuration for my servers + other stuff";

  inputs = {
    # Required for nix to recognize the git submodule as a valid nix module
    # secrets = {
    #   url = "path:secrets"; # the submodule is in the ./subproject dir
    #   flake = false;
    # };

    nixpkgs = {
      url = "github:nixos/nixpkgs/release-24.05";
    };

    # Core tools: home manager, secrets, disk partitioning, deployment
    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

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

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # impermanence = {
    #   url = "github:nix-community/impermanence";
    # };

    # https://docs.hercules-ci.com/arion/
    # arion = {
    #   url = "github:hercules-ci/arion";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # microvm = {
    #   url = "github:astro/microvm.nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    agenix,
    deploy-rs,
    nix-darwin,
    ...
  } @ inputs: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-darwin"
      # "aarch64-linux"
      # "x86_64-darwin"
    ];
    forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {pkgs = import nixpkgs {inherit system;};});

    deployPkgs = forEachSupportedSystem (
      {pkgs}:
        import nixpkgs {
          inherit (pkgs) system;
          overlays = [
            deploy-rs.overlay # or deploy-rs.overlays.default
            (self: super: {
              deploy-rs = {
                inherit (pkgs) deploy-rs;
                lib = super.deploy-rs.lib;
              };
            })
          ];
        }
    );
  in {
    # Dev shell for this flake (mostly for reference)
    devShells = forEachSupportedSystem (
      {pkgs}: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nixd
            git
          ];
        };
      }
    );

    # Standard formatter for this flake
    formatter = forEachSupportedSystem ({pkgs}: pkgs.alejandra);

    # Config for my macbook (only used to set up my terminal)
    darwinConfigurations.pepacton = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [agenix.darwinModules.default];
    };

    # Config for my servers
    nixosConfigurations = {
      barnegat = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {
          inherit inputs;
        };

        modules = [
          # Machine config
          ./machines/nixos
          ./machines/nixos/barnegat
          disko.nixosModules.default
          # Custom disk config is in the machine config

          # Secrets
          ./secrets
          agenix.nixosModules.default

          # User config
          ./users/henrikvt
        ];
      };
      donso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {
          inherit inputs;
        };

        modules = [
          # Machine config
          ./machines/nixos
          ./machines/nixos/donso
          disko.nixosModules.default

          # ./modules/boot-disk See notes in boot-disk-gb for why this is like this
          ./modules/nixos/boot-disk-gb

          # Secrets
          ./secrets
          agenix.nixosModules.default

          # User config
          ./users/henrikvt
        ];
      };
      svalbard = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {
          inherit inputs;
        };

        modules = [
          # Machine config
          ./machines/nixos
          ./machines/nixos/svalbard
          disko.nixosModules.default

          ./modules/nixos/boot-disk-gb

          # Secrets
          ./secrets
          agenix.nixosModules.default

          # User config
          ./users/henrikvt
        ];
      };
      marstrand = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {
          inherit inputs;
        };

        modules = [
          # Machine config
          ./machines/nixos
          ./machines/nixos/marstrand
          disko.nixosModules.default

          ./modules/nixos/boot-disk-gb

          # Secrets
          ./secrets
          agenix.nixosModules.default

          # User config
          ./users/henrikvt
        ];
      };
      valcour = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {
          inherit inputs;
        };

        modules = [
          # Machine config
          ./machines/nixos
          ./machines/nixos/valcour
          disko.nixosModules.default

          ./modules/nixos/boot-disk

          # Secrets
          ./secrets
          agenix.nixosModules.default

          # User config
          ./users/henrikvt
        ];
      };
    };

    deploy = {
      fastConnection = true;
      remoteBuild = true;
      user = "root";
      sshUser = "henrikvt";

      # nodes config
      nodes = {
        barnegat = {
          hostname = "barnegat";
          sshOpts = [
            "-p"
            "69"
          ];
          profiles.system.path =
            deployPkgs."x86_64-linux".deploy-rs.lib.activate.nixos
            self.nixosConfigurations.donso;
        };
        donso = {
          hostname = "donso";
          profiles.system.path =
            deployPkgs."x86_64-linux".deploy-rs.lib.activate.nixos
            self.nixosConfigurations.donso;
        };
        marstrand = {
          hostname = "marstrand";
          profiles.system.path =
            deployPkgs."x86_64-linux".deploy-rs.lib.activate.nixos
            self.nixosConfigurations.marstrand;
        };
        svalbard = {
          hostname = "svalbard";
          profiles.system.path =
            deployPkgs."x86_64-linux".deploy-rs.lib.activate.nixos
            self.nixosConfigurations.svalbard;
        };
        valcour = {
          hostname = "valcour";
          profiles.system.path =
            deployPkgs."x86_64-linux".deploy-rs.lib.activate.nixos
            self.nixosConfigurations.valcour;
        };
      };
    };

    # Enables nix flake check to ensure that the deploy-rs config is correct
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}

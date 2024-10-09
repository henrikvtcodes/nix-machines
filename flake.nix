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

    systems.url = "github:nix-systems/default";

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

  outputs =
    {
      self,
      nixpkgs,
      disko,
      agenix,
      deploy-rs,
      systems,

      ...
    }@inputs:
    let
      lib = nixpkgs.lib;

      forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});

      pkgsFor = lib.genAttrs (import systems) (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );

      deployPkgs = forEachSystem (
        pkgs:
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

    in
    {

      # devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs; });

      formatter = {
        x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
        aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
      };

      nixosConfigurations = {
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

            ./modules/tailscale
            # ./modules/boot-disk See notes in boot-disk-gb for why this is like this
            ./modules/boot-disk-gb

            # Secrets
            ./secrets
            agenix.nixosModules.default

            # User config
            ./users/henrikvt
          ];
        };
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

            ./modules/tailscale

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

            ./modules/tailscale
            ./modules/boot-disk-gb

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

            ./modules/tailscale
            ./modules/boot-disk-gb

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
          svalbard = {
            hostname = "svalbard";
            profiles.system.path = deployPkgs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.svalbard;
          };
          valcour = {
            hostname = "valcour";
            profiles.system.path = deployPkgs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.valcour;
          };
          marstrand = {
            hostname = "marstrand";
            profiles.system.path = deployPkgs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.marstrand;
          };
          barnegat = {
            hostname = "barnegat";
            sshOpts = [
              "-p"
              "69"
            ];
            profiles.system.path = deployPkgs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.barnegat;
          };
          donso = {
            hostname = "donso";
            profiles.system.path = deployPkgs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.donso;
          };
        };
      };

      # Enables nix flake check to ensure that the deploy-rs config is correct
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };

}

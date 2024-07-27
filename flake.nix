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
      ...
    }@inputs:
    {

      # devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs; });

      nixosConfigurations = {
        doghouse = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = {
            inherit inputs;
          };

          modules = [
            # Machine config
            ./machines/nixos
            ./machines/nixos/doghouse
            disko.nixosModules.default

            ./modules/tailscale
            ./modules/boot-disk

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
            ./modules/boot-disk

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
          doghouse = {
            hostName = "doghouse";
            profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.doghouse;
          };
        };
      };

      # Enables nix flake check to ensure that the deploy-rs config is correct
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };

}

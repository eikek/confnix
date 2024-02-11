{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    #    flake-compat.url = "github:edolstra/flake-compat";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    #nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      #inputs.darwin.follows = ""; #pulls in home-manager otherwise
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dsc = {
      #url = "path:///home/eike/workspace/projects/dsc";
      url = "github:docspell/dsc";
    };
    ds4e.url = "github:docspell/ds4e";
  };

  outputs = inputs@{ self, flake-parts, nixpkgs, agenix, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ withSytem, ... }:
      let system = "x86_64-linux";
      in {
        systems = [ system ];

        perSystem = { config, system, pkgs, ... }: {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [ agenix.overlays.default ];
          };

          devShells.default = with pkgs;
            mkShell { buildInputs = [ nixfmt pkgs.agenix ]; };

          formatter = pkgs.nixpkgs-fmt;
        };
        flake = {
          nixosConfigurations.poros = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = inputs;
            modules = [ ./machines/poros/configuration.nix ];
          };
          nixosConfigurations.kalamos = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = inputs;
            modules = [
              ./machines/kalamos/configuration.nix
              ./machines/kalamos/monitor-ext.nix
            ];
          };
          nixosConfigurations.kalamos-amd = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = inputs;
            modules = [
              ./machines/kalamos/configuration.nix
              ./machines/kalamos/monitor-int.nix
            ];
          };
          nixosConfigurations.limnos = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = inputs;
            modules = [ ./machines/limnos/configuration.nix ];
          };
        };
      });
}

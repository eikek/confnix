{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    #    flake-compat.url = "github:edolstra/flake-compat";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      #inputs.darwin.follows = "";
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
    webact = {
      url = "github:eikek/webact";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flake-parts, nixpkgs, agenix, dsc, ds4e, webact, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, ... }:
      let
        defaultSystem = "x86_64-linux";

        # taken from here: https://github.com/buntec/nix-config/blob/27d463989a19eff56adc4154c86d3cda01bc8dbf/flake.nix#L74
        overlays = [
          (final: prev: {
            unstable = import inputs.nixpkgs-unstable {
              inherit (prev) system;
              config = { allowUnfree = true; };
            };
          })
          # pick packages from unstable
          (final: prev: {
            inherit (final.unstable) jetbrains scala-cli quivira;
          }
          )
          self.overlays.default
          webact.overlays.default
          ds4e.overlays.default
          #dsc.overlays.default <- this makes dsc compile under 23.11 and not using nixpkgs from dsc flake
          (final: prev: {
            dsc = dsc.packages.${final.system}.default;
          })
        ];

        pkgsBySystem = system: import nixpkgs {
          inherit system;
          inherit overlays;
          config = { allowUnfree = true; };
        };

        mkNixos = modules: nixpkgs.lib.nixosSystem {
          system = defaultSystem;
          specialArgs = inputs;
          modules = [{ nixpkgs.pkgs = pkgsBySystem defaultSystem; }] ++ modules;
        };
      in
      {
        systems = [ defaultSystem "i686-linux" ];

        perSystem = { config, system, pkgs, ... }:
          {
            _module.args.pkgs = import nixpkgs {
              inherit system;
              overlays = [
                agenix.overlays.default
                (final: prev: { ds4e = ds4e.packages.${system}.default; })
              ];
            };

            packages = (import ./pkgs) pkgs;

            devShells.default = with pkgs;
              mkShell { buildInputs = [ nixfmt pkgs.agenix ]; };

            formatter = pkgs.nixpkgs-fmt;
          };

        flake = {
          overlays.default = final: prev: withSystem prev.stdenv.hostPlatform.system (
            { config, ... }: config.packages
          );

          nixosConfigurations.kalamos = mkNixos [
            ./machines/kalamos/configuration.nix
            ./machines/kalamos/monitor-ext.nix
          ];

          nixosConfigurations.kalamos-amd = mkNixos [
            ./machines/kalamos/configuration.nix
            ./machines/kalamos/monitor-int.nix
          ];

          nixosConfigurations.poros = mkNixos [
            ./machines/poros/configuration.nix
          ];

          nixosConfigurations.limnos = mkNixos [
            ./machines/limnos/configuration.nix
          ];
        };
      });
}

{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    #    flake-compat.url = "github:edolstra/flake-compat";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    #nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    dsc = {
      #url = "path:///home/eike/workspace/projects/dsc";
      url = "github:docspell/dsc";
      # inputs.nixpkgs.follows = "nixpkgs-unstable";
      # inputs.naersk.follows = "naersk";
    };
    ds4e.url = "github:docspell/ds4e";
  };

  outputs = { self, nixpkgs, agenix, ... }@attrs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      nixosConfigurations.poros = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = attrs;
        modules = [ ./machines/poros/configuration.nix ];
      };
      nixosConfigurations.kalamos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = attrs;
        modules = [
          ./machines/kalamos/configuration.nix
          ./machines/kalamos/monitor-ext.nix
        ];
      };
      nixosConfigurations.kalamos-amd = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = attrs;
        modules = [
          ./machines/kalamos/configuration.nix
          ./machines/kalamos/monitor-int.nix
        ];
      };
      nixosConfigurations.limnos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = attrs;
        modules = [ ./machines/limnos/configuration.nix ];
      };

      devShells.${system}.default = pkgs.mkShellNoCC {
        buildInputs = with pkgs; [ nixfmt agenix.packages.${system}.default ];
      };
    };
}

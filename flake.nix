{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-23.11;

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    #nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-hardware, agenix }@attrs: {
    nixosConfigurations.poros = nixpkgs.lib.nixosSystem {
      system = "x84_64-linux";
      specialArgs = attrs;
      modules = [
        ./machines/poros/configuration.nix
      ];
    };
    nixosConfigurations.kalamos = nixpkgs.lib.nixosSystem {
      system = "x84_64-linux";
      specialArgs = attrs;
      modules = [
        ./machines/kalamos/configuration.nix
      ];
    };
  };
}

{
  network.description = "Test FileShelter";

  fileshelter =
    { config, pkgs, ... }:
    {
      imports = [ ./default.nix ../extra-ids/default.nix ];

      services.fileshelter = {
        enable = true;
        bindHost = "0.0.0.0";
      };

      networking = {
        firewall = {
          allowedTCPPorts = [ 5091 ];
        };
      };

      nixpkgs = {
        config = {
          packageOverrides = import ../../pkgs;
        };
      };

      deployment.targetEnv = "container";
    };

}

{
  network.description = "Test Sharry";

  sharry =
    { config, pkgs, ... }:
    {
      imports = [ ./default.nix ../extra-ids/default.nix ];

      services.sharry = {
        enable = true;
        bindHost = "0.0.0.0";
      };

      networking = {
        firewall = {
          allowedTCPPorts = [ 9090 ];
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

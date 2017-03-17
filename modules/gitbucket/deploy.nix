{
  network.description = "Test Gitbucket";

  gitbucket =
    { config, pkgs, ... }:
    {
      imports = [ ./default.nix ../extra-ids/default.nix ];

      services.gitbucket = {
        enable = true;
        httpPort = 9100;
        bindHost = "0.0.0.0";
        baseUrlHost = "10.233.2.2";
      };

      networking = {
        firewall = {
          allowedTCPPorts = [ 9100 29418];
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

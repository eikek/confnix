# then create a container with nixops (only first time)
#    nixops create -d sharry deploy.nix
#
# first build the app
#    sbt assembly
#
# start it
#    nixops deploy -d sharry
#
# connect your browser to the ip address of the container
#
{
  network.description = "Test Sharry Module";

  sharry =
    { config, pkgs, ... }:
    {
      imports = [ ./default.nix ../extra-ids/default.nix ];

      networking = {
        firewall = {
          allowedTCPPorts = [ 9090 80 ];
        };
      };

      services.sharry = {
        enable = true;
        bindHost = "0.0.0.0";
        authenticationEnabled = false;
      };

      nixpkgs = {
        config = {
          packageOverrides = import ../../pkgs;
        };
      };


      services.nginx = {
        enable = true;
        httpConfig = ''
         server {
           listen 0.0.0.0:80;

           proxy_request_buffering off;
           proxy_buffering off;

           location / {
              proxy_pass http://127.0.0.1:9090;
              # this is important, because fs2-http can only do 1.1
              # and it effectively disables request_buffering
              proxy_http_version 1.1;
              proxy_read_timeout  120;
           }
         }
        '';
      };

      deployment.targetEnv = "container";
    };
}

{ config, pkgs, lib, ... }:
with config;
let
  subdomain = "sharrydemo";
  shelterHttpPort = builtins.toString config.services.shelter.httpPort;
  authscript = pkgs.writeScript "sharrydemo-auth.sh" ''
  #!${pkgs.bash}/bin/bash -e
  [[ "$1" = "sharry" ]]
  '';
in
{

  services.sharrydemo = {
    enable = true;
    bindPort = 9320;
    maxFileSize = "1.5M";
    baseUrl = (if (settings.useCertificate) then "https://" else "http://") +
              subdomain + "." + settings.primaryDomain + "/";
    enableMail = false;
    maxValidity = "16 hours";
    cleanupEnable = true;
    cleanupInterval = "8 hours";
    cleanupIntervalAge = "2 minutes";
    authenticationEnabled = true;
    welcomeMessage = ''### Welcome to Sharry demo instance

Please login as user `sharry` and any password to start exploration.'';
    extraConfig = ''
    authc.extern.command {
      enable = true
      program = [
        "${authscript}"
        "{login}"
      ]
    }
    '';
  };

  services.bindExtra.subdomains = [ subdomain ];

  services.nginx.httpConfig =
    (if (settings.useCertificate) then ''
    server {
        listen ${settings.primaryIp}:80;
        server_name ${subdomain}.${settings.primaryDomain};
        return 301 https://${subdomain}.${settings.primaryDomain}$request_uri;
    }
   '' else "") + ''
   server {
     listen  ${settings.primaryIp}:${if (settings.useCertificate) then "443 ssl" else "80"};
     server_name ${subdomain}.${settings.primaryDomain};

     proxy_request_buffering off;
     proxy_buffering off;

     location / {
        proxy_pass http://127.0.0.1:${builtins.toString services.sharrydemo.bindPort};
        proxy_http_version 1.1;
     }
   }
  '';
}

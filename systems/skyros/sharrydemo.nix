{ config, pkgs, lib, ... }:
with config;
let
  subdomain = "sharrydemo";
  shelterHttpPort = builtins.toString config.services.shelter.httpPort;
in
{

  services.sharrydemo = {
    enable = true;
    bindPort = 9320;
    maxFileSize = "500K";
    baseUrl = (if (settings.useCertificate) then "https://" else "http://") +
              subdomain + "." + settings.primaryDomain + "/";
    enableMail = false;
    maxValidity = "6 hours";
    cleanupEnable = true;
    cleanupInterval = "8 hours";
    cleanupIntervalAge = "2 minutes";
    authenticationEnabled = false;
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

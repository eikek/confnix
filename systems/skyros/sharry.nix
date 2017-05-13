{ config, pkgs, lib, ... }:
with config;
let
  subdomain = "files";
  shelterHttpPort = builtins.toString config.services.shelter.httpPort;
in
{

  services.sharry = {
    enable = true;
    bindPort = 9310;
    maxFileSize = "5G";
    baseUrl = (if (settings.useCertificate) then "https://" else "http://") +
              subdomain + "." + settings.primaryDomain + "/";
    enableMail = true;
    maxValidity = "365 days";
    cleanupEnable = true;
    extraConfig = ''
    authc.extern.http {
      enable = true
      url = "http://localhost:${shelterHttpPort}/api/verify/json"
      method = "POST"
      body = """{ "login": "{login}", "password": "{password}", "appid": "files" }"""
      content-type = "application/json"
    }
    smtp {
      host = localhost
      port = 25
      from = "noreply@${settings.primaryDomain}"
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
        proxy_pass http://127.0.0.1:${builtins.toString services.sharry.bindPort};
        proxy_http_version 1.1;
     }
   }
  '';

}

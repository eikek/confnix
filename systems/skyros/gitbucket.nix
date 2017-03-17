{ config, pkgs, lib, ... }:
with config;
let
  shelterHttpPort = builtins.toString config.services.shelter.httpPort;
  subdomain = "git";
in
{

  services.gitbucket = {
    enable = true;
    baseUrlHost = "${subdomain}.${settings.primaryDomain}";
    baseUrl = (if (settings.useCertificate) then "https://" else "http://") +
              subdomain + "." + settings.primaryDomain;
    useSMTP = true;
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
     location / {
        proxy_pass http://127.0.0.1:${builtins.toString services.gitbucket.httpPort};
        proxy_set_header X-Forwarded-For   $remote_addr;
        proxy_set_header Host              $host;
        proxy_set_header X-Forwarded-Proto $scheme;
     }
   }
  '';
}

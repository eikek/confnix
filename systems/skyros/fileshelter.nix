{ config, pkgs, lib, ... }:
with config;
let
  subdomain = "files";
in
{

  services.fileshelter = {
    enable = true;
    httpPort = 9310;
    appName = "Files!";
    behindReverseProxy = true;
    maxFileSize = 600;
    tosOrg = "eknet.org";
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
     proxy_buffer_size 4k;

     location / {
        proxy_pass http://127.0.0.1:${builtins.toString services.fileshelter.httpPort};
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header Host              $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout  120;
     }
   }
  '';

}

{ config, pkgs, lib, ... }:
with config;
let
  subdomain = "bag";
in
{

  services.sitebag = {
    urlBase = (if (settings.useCertificate) then "https://" else "http://") + subdomain + "." + settings.primaryDomain +"/";
    porter.externalAuthentication = {
      urlPattern = "http://localhost:${builtins.toString config.services.shelter.httpPort}/api/verify/form?login=%[username]&password=%[password]&app=sitebag";
      usePost = true;
    };
    webui.enableChangePasswordForm = false;
  };

  services.bindExtra.subdomains = if (services.sitebag.enable) then [ subdomain ] else [];

  services.shelter.apps = [{
    id = "sitebag";
    name = "Sitebag";
    url= ((if (settings.useCertificate) then "https://" else "http://")+subdomain+"."+settings.primaryDomain);
    description = "Sitebag read-it-later web application.";
  }];

  services.nginx.httpConfig = if (services.sitebag.enable) then
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
     location = / {
        return 301 ${if (settings.useCertificate) then "https://" else "http://"}${subdomain}.${settings.primaryDomain}/ui/;
     }
     location / {
        proxy_pass http://${services.sitebag.bindHost}:${builtins.toString services.sitebag.bindPort};
        proxy_set_header X-Forwarded-For $remote_addr;
     }
   }
  '' else "";
}

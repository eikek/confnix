{ config, pkgs, lib, ... }:
with config;
let
  subdomain = "git";
in
{

  services.gitea = {
    enable = true;
    database.type = "sqlite3";
    appName = "eknet's Gitea";
    user = "git";
    domain = settings.primaryDomain;
    rootUrl = (if (settings.useCertificate) then "https://" else "http://") +
              subdomain + "." + settings.primaryDomain;
    httpPort = 9110;
    extraConfig = ''
      [service]
      DEFAULT_KEEP_EMAIL_PRIVATE = true
      ENABLE_NOTIFY_MAIL = true

      [mailer]
      ENABLED = true
      HOST = ${settings.primaryDomain}:25
      HELO_HOSTNAME = ${settings.primaryDomain}
      FROM = git-noreply@${settings.primaryDomain}

      [log]
      LEVEL = Warn
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
     location / {
        proxy_pass http://127.0.0.1:${builtins.toString services.gitea.httpPort};
        proxy_set_header X-Forwarded-For   $remote_addr;
        proxy_set_header Host              $host;
        proxy_set_header X-Forwarded-Proto $scheme;
     }
   }
  '';
}

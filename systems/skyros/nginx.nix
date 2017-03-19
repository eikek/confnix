{ config, pkgs, lib, ... }:
with config;
with lib;
let
   shelterHttpPort = builtins.toString config.services.shelter.httpPort;
   nginxExtras = config.services.nginxExtra;
   protectedConfig = concatMapStringsSep "\n" (m: ''
       location ${m.path} {
          set $appid "${m.app}";
          auth_request /auth;
          auth_request_set $originalurl $scheme://$host$request_uri$query_string;

          ${if (builtins.hasAttr "config" m) then m.config else ""}
        }
      '') nginxExtras.protectedPaths;
in
{

  options = {
    services.phpfpmExtra = {
      fastCgiBinding = mkOption {
        default = "127.0.0.1:9000";
        description = "The socket address to bind php-fpm to.";
      };
    };
    services.nginxExtra = {
      protectedPaths = mkOption {
        default = [];
        description = ''A list of maps defining a path, a app and a config property. The path
          is configured to be protected with nginx (using shelter) and only users enabled for the
          specified app may enter. Users are redirected to a login page, if necessary. The
          config property is additional nginx configuration that is inserted verbatim.'';
      };
    };
  };

  config = mkIf settings.enableWebServer {
    services.phpfpm = {
      poolConfigs = {
        mypool = ''
          listen = ${services.phpfpmExtra.fastCgiBinding}
          user = ${config.services.nginx.user}
          pm = dynamic
          pm.max_children = 75
          pm.start_servers = 5
          pm.min_spare_servers = 2
          pm.max_spare_servers = 20
          pm.max_requests = 500
        '';
      };
      #roundcube needs php5, this is only for roundcube…
      phpPackage = pkgs.php56;
      phpOptions = ''
        date.timezone = "UTC"
        post_max_size = 20M
        upload_max_filesize = 12M
      '';
    };

    services.logrotate = {
      config = let spool = config.services.nginx.stateDir; in ''
        ${spool}/logs/access.log ${spool}/logs/error.log {
          monthly
          rotate 12
          sharedscripts
          postrotate
            ${pkgs.coreutils}/bin/kill -USR1 $(cat ${spool}/logs/nginx.pid)
          endscript
        }
      '';
    };

    services.nginx =  {
      enable = config.settings.enableWebServer;
      httpConfig = ''
        include       ${pkgs.nginx}/conf/mime.types;
        default_type  application/octet-stream;
        sendfile        on;
        keepalive_timeout  65;
        gzip on;
        gzip_min_length 1024;
        gzip_buffers 4 32k;
        gzip_types text/plain text/html application/x-javascript text/javascript text/xml text/css;
        client_max_body_size 20m;

        ${if (settings.useCertificate) then ''
         ssl_session_cache    shared:SSL:10m;
         ssl_session_timeout  10m;
         ssl_certificate      ${settings.certificate};
         ssl_certificate_key  ${settings.certificateKey};
         #ssl_ciphers  HIGH:!aNULL:!MD5;
         #ssl_ciphers RC4:HIGH:!aNULL:!MD5;
         ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
         ssl_ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS;
         ssl_prefer_server_ciphers   on;

         server {
           listen ${settings.primaryIp}:80;
           server_name www.${settings.primaryDomain} ${settings.primaryDomain};
           return 301 https://${settings.primaryDomain}$request_uri;
         }
        '' else ""}

        server {
          listen ${settings.primaryIp}:${if (settings.useCertificate) then "443 ssl" else "80"};
          server_name www.${settings.primaryDomain} ${settings.primaryDomain};
          root /var/data/www/${settings.primaryDomain};
          index index.html index.php;

          location / {
            try_files $uri $uri/ /index.php;
          }
          location ~ \.php$ {
            fastcgi_pass ${services.phpfpmExtra.fastCgiBinding};
            fastcgi_index index.php;
            include ${pkgs.nginx}/conf/fastcgi_params;
            include ${pkgs.nginx}/conf/fastcgi.conf;
          }

          ${if ((length nginxExtras.protectedPaths) > 0) then ''
          error_page 401 = @error401;

          location @error401 {
            return 302 http://id.${settings.primaryDomain}/signin.html?to=$originalurl&app=$appid;
          }
          location = /auth {
            internal;
            proxy_pass http://localhost:${shelterHttpPort}/api/verify/cookie;
            proxy_pass_request_body off;
            proxy_set_header Content-Length "";
            proxy_set_header X-Shelter-App $appid;
          }
          ${protectedConfig}
          '' else ""}
        }
      '';
    };
  };
}

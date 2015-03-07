{ config, pkgs, lib, ... }:
with config;
with lib;
let
   myphpini = pkgs.stdenv.mkDerivation {
     name = "myphpini";
     src = config.services.phpfpm.phpPackage;
     installPhase = ''
       mkdir -p $out
       sed 's/;date.timezone =/date.timezone = "UTC"/' etc/php-recommended.ini > $out/php.ini
     '';
   };
in
{

  options = {
    services.phpfpmExtra = {
      fastCgiBinding = mkOption {
        default = "127.0.0.1:9000";
        description = "The socket address to bind php-fpm to.";
      };
    };
  };

  config = mkIf settings.enableWebServer {
    services.phpfpm = {
      phpIni = myphpini;
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
      # extraConfig = ''
      # log_level = debug
      # '';
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
        }
      '';
    };
  };
}

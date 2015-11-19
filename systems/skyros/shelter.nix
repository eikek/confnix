{ config, pkgs, lib, ... }:
with config;
with lib;
let
  htmlManager = pkgs.stdenv.mkDerivation rec {
    name = "shelter-manager";
    src = ./shelterman;
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/{css,js}
      cp ${pkgs.jquery2}/js/jquery.min.js $out/js/jquery.min.js
      cp ${pkgs.kube}/css/kube.min.css $out/css/kube.min.css
      cp $src/css/* $out/css/
      cp $src/js/* $out/js/
      cp $src/*.html $out/
    '';
    /**/
  };
  shelterVar = config.services.shelter.baseDir;
in
{
  options = {
    services.shelter = {
       apps = mkOption {
         default = [];
         description = ''
           A list of maps with <literal>id</literal> and <literal>name</literal>
           properties that denote an application. These are added to shelter.
         '';
         example = [{id = "mail";
                     name = "Email";
                     url = "http://the.url.com";
                     description = "SMTP and IMAP Services.";}];
       };
    };
  };

  config = {

    services.shelter = {
      enable = true;
      autoLoad = ''
      (add-setpassword-routes)
      (add-verify-routes)
      (add-listapps-route)
      (add-logout-route)
      (add-account-exists-route)
      (rest/apply-routes)

      (config/set {:cookie-secure ${if (settings.useCertificate) then "true" else "false"}
                   :cookie-domain ".${settings.primaryDomain}"})

      (defn- shelter--app-add [id name & [url description]]
        (store/with-conn conn
          (if (not (account/app-exists? conn id))
            (account/app-set conn {:appid id :appname name :url url :description description}))))

      ${concatMapStringsSep "\n" (app: ''(shelter--app-add "${app.id}" "${app.name}" "${app.url}" "${app.description}")'') services.shelter.apps}
      '';
      loadFiles = [ "${shelterVar}/shelterrc.clj" ];
    };

    services.nginx.httpConfig = ''
      ${if (settings.useCertificate) then ''
       server {
         listen ${settings.primaryIp}:80;
         server_name id.${settings.primaryDomain};
         return 301 https://id.${settings.primaryDomain}$request_uri;
       }
      '' else ""}
      server {
        listen ${settings.primaryIp}:${if (settings.useCertificate) then "443 ssl" else "80"};
        server_name id.${settings.primaryDomain};
        root ${htmlManager};
        index index.html;
        location / {
          try_files $uri $uri/ /index.html;
        }
        location /api {
          proxy_pass http://127.0.0.1:${builtins.toString config.services.shelter.httpPort};
          proxy_set_header X-Forwarded-For $remote_addr;
        }
      }
    '';

    services.bindExtra.subdomains = [ "id" ];
  };
}

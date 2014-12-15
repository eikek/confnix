{ config, pkgs, lib, ... }:
with config;
with lib;
let
  shelterVar = config.services.shelter.baseDir;
  htmlManager = ./shelterman;
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
      (in-ns 'shelter.core)
      (add-setpassword-routes)
      (add-verify-routes)
      (add-listapps-route)
      (rest/apply-routes)

      (config/set {:cookie-secure ${if (settings.useCertificate) then "true" else "false"}})

      (defn- shelter--app-add [id name & [url description]]
        (store/with-conn conn
          (if (not (account/app-exists? conn id))
            (account/app-set conn {:appid id :appname name :url url :description description}))))

      ${concatMapStringsSep "\n" (app: ''(shelter--app-add "${app.id}" "${app.name}" "${app.url}" "${app.description}")'') services.shelter.apps}
      '';
      loadFiles = [ "${shelterVar}/shelterrc.clj" ];
    };

    services.nginx.httpConfig = ''
      server {
        listen ${settings.primaryIp}:${if (settings.useCertificate) then "443 ssl" else "80"};
        server_name id.${settings.primaryDomain};
        root ${htmlManager};
        index index.html index.php;
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

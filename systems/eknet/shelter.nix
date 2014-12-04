{ config, pkgs, lib, ... }:
with config;
with lib;
let
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
         example = [{ id = "mail"; name = "SMTP and IMAP services."; }];
       };
    };
  };

  config = {

    services.shelter = {
      enable = true;
      autoLoad = ''
      (in-ns 'shelter.core)
      (add-rest-verify-route)
      (rest/apply-routes)

      (defn- shelter--app-add [id name]
        (if (not (account/app-exists? id))
          (account/add-application id name)))

      ${concatMapStringsSep "\n" (app: ''(shelter--app-add "${app.id}" "${app.name}")'') services.shelter.apps}
      '';
      loadFiles = [ "${shelterVar}/shelterrc.clj" ];
    };
  };
}

{config, lib, pkgs, ...}:

with lib;
let
  cfg = config.services.shelter;
  autoload = pkgs.writeText "shelter-autoload.clj" ''
    (in-ns 'shelter.core)
    ${cfg.autoLoad}
  '';
  dbrc = pkgs.writeText "shelter-db.clj" ''
    (in-ns 'shelter.core)
    (config/set {:database "${cfg.databaseFile}"
                 :nrepl-port ${builtins.toString cfg.nreplPort}
                 :rest-port ${builtins.toString cfg.httpPort}})
  '';
in {

  ## interface
  options = {
    services.shelter = {
      enable = mkOption {
        default = false;
        description = "Whether to enable shelter.";
      };

      nreplPort = mkOption {
        default = 7900;
        description = "The port used to bind the nrepl server.";
      };

      httpPort = mkOption {
        default = 7910;
        description = "The port used to bind the http rest server.";
      };

      baseDir = mkOption {
        default = "/var/data/shelter";
        description = "Location where shelter puts the database.";
      };

      databaseFile = mkOption {
        default = "${cfg.baseDir}/users.db";
        description = "Path to the file containing the sqlite database.";
      };

      autoLoad = mkOption {
        default = null;
        description = "Clojure code to automatically load on startup. The code is evaluated inside shelter.core namespace.";
      };

      loadFiles = mkOption {
        default = [];
        description = "A list of paths to clojure files that are loaded by shelter on start.";
      };
    };
  };

  ## implementation
  config = mkIf config.services.shelter.enable {
    users.extraGroups = singleton {
      name = "shelter";
      gid = config.ids.gids.shelter;
    };

    users.extraUsers = singleton {
      name = "shelter";
      uid = config.ids.uids.shelter;
      extraGroups = [ "shelter" ];
      description = "Shelter daemon user.";
    };

    systemd.services.shelter = {
      description = "Shelter server";
      after = [ "networking.target" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        mkdir -p ${cfg.baseDir}
        chown shelter:shelter ${cfg.baseDir}
        chown shelter:shelter ${cfg.databaseFile}
        chmod 644 ${cfg.databaseFile}
      '';

      script = "${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh shelter -c \"${pkgs.shelter}/bin/shelter ${dbrc} ${if (cfg.autoLoad == null) then "" else "${autoload}"} ${builtins.toString cfg.loadFiles} \"";
    };
  };
}

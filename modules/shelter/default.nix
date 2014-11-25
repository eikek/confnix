{config, lib, pkgs, ...}:

with lib;
let
  cfg = config.services.shelter;
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
        default = "/var/shelter";
        description = "Location where shelter puts the database.";
      };

      databaseFile = mkOption {
        default = "${cfg.baseDir}/users.db";
        description = "Path to the file containing the sqlite database.";
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

    environment.systemPackages = [ pkgs.shelter ];

    jobs.shelter = {
      description = "Shelter server";
      startOn = "ip-up";
      daemonType = "none";

      preStart = ''
        mkdir -p ${cfg.baseDir}
        chown shelter:shelter ${cfg.baseDir}
        cat > ${cfg.baseDir}/db.clj <<-"EOF"
        (in-ns 'shelter.core)
        (config/set {:database "${cfg.databaseFile}"
                     :nrepl-port ${builtins.toString cfg.nreplPort}
                     :rest-port ${builtins.toString cfg.httpPort}})
        EOF
        if ! [ -r ${cfg.databaseFile} ]; then
          touch ${cfg.databaseFile}
        fi
        chown shelter:shelter ${cfg.databaseFile}
        chmod 640 ${cfg.databaseFile}
      '';

      exec = "${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh shelter -c \"${pkgs.shelter}/bin/shelter ${cfg.baseDir}/db.clj ${builtins.toString cfg.loadFiles} \"";
    };
  };
}

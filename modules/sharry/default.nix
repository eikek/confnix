{config, lib, pkgs, ...}:

with lib;
let
  cfg = config.services.sharry;
  str = e: if (builtins.typeOf e) == "bool" then (if e then "true" else "false") else (builtins.toString e);
  user = "sharry";
  sharryConf = pkgs.writeText "sharry.conf" ''
  sharry {
      db {
        driver = "${cfg.jdbcDriver}"
        url = "${cfg.jdbcUrl}"
        user = "${cfg.jdbcUser}"
        password = "${cfg.jdbcPassword}"
      }

      log {
        config = "${cfg.logConfigFile}"
      }

      upload {
        chunk-size = "256K"
        simultaneous-uploads = ${str cfg.simultaneousUploads}
        max-files = ${str cfg.maxFiles}
        max-file-size = "${cfg.maxFileSize}"
        cleanup-enable = true
        cleanup-interval = 30 days
        cleanup-invalid-age = 7 days
      }

      web {
        bind-host = "${cfg.bindHost}"
        bind-port = ${str cfg.bindPort}
        app-name = "${cfg.appName}"
        baseurl = "${cfg.baseUrl}"
      }
      authc.enable = ${str cfg.authenticationEnabled}

      ${cfg.extraConfig}
    }
  '';
in {

  ## interface
  options = {
    services.sharry = {
      enable = mkOption {
        default = false;
        description = "Whether to enable sharry.";
      };

      bindHost = mkOption {
        default = "localhost";
        description = "The hostname/ip to bind to";
      };

      bindPort = mkOption {
        default = 9090;
        description = "The port for the http connector. A number &lt;= 0 disables http.";
      };

      jdbcDriver = mkOption {
        default = "org.h2.Driver";
        description = "The JDBC driver class name.";
      };

      jdbcUser = mkOption {
        default = "sa";
        description = "The username for JDBC connection";
      };

      jdbcPassword = mkOption {
        default = "";
        description = "The jdbc database password";
      };

      jdbcUrl = mkOption {
        default = "jdbc:h2:./sharry-db.h2";
        description = "The JDBC database url.";
      };

      logConfigFile = mkOption {
        default = "";
        description = "An optional logback configuration file";
      };

      appName = mkOption {
        default = "Sharry";
        description = "The application name in the top left.";
      };

      baseUrl = mkOption {
        default = "http://localhost:9090/";
        description = "The base url used to construct links. Must end with a slash!";
      };

      simultaneousUploads = mkOption {
        default = 3;
        description = "Number of simultaneous uploads";
      };

      maxFiles = mkOption {
        default = 50;
        description = "Maximum number of files to upload at once";
      };

      maxFileSize = mkOption {
        default = "1.5G";
        description = "Maximum size of the files to be uploaded, suffixes: M or G";
      };

      authenticationEnabled = mkOption {
        default = true;
        description = "Enable authentication or not";
      };

      extraConfig = mkOption {
        default = "";
        description = "More configuration that is appended";
      };

      dataDir = mkOption {
        default = "/var/data/sharry";
        description = ''
          A data directory used for the H2 database. Note that
          you should use a relative path for jdbcUrl then or leave the default.
        '';
      };
    };
  };

  ## implementation
  config = mkIf cfg.enable {
    users.extraGroups = singleton {
      name = user;
      gid = config.ids.gids.sharry;
    };

    users.extraUsers = singleton {
      name = user;
      uid = config.ids.uids.sharry;
      extraGroups = ["sharry"];
      description = "sharry daemon user.";
    };

    systemd.services.sharry = {
      description = "sharry";
      after = [ "networking.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        if [ ! -d "${cfg.dataDir}" ]; then
          mkdir -p ${cfg.dataDir}
          chown sharry:sharry ${cfg.dataDir}
        fi
      '';

      script = ''
        ${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh ${user} -c "cd ${cfg.dataDir} && ${pkgs.sharry}/bin/sharry-server ${sharryConf}"
      '';
    };
  };
}

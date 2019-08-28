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
        chunk-size = "${cfg.chunkSize}"
        simultaneous-uploads = ${str cfg.simultaneousUploads}
        max-files = ${str cfg.maxFiles}
        max-file-size = "${cfg.maxFileSize}"
        max-validity = "${cfg.maxValidity}"
        cleanup-enable = ${str cfg.cleanupEnable}
        cleanup-interval = ${cfg.cleanupInterval}
        cleanup-invalid-age = ${cfg.cleanupIntervalAge}
        alias-delete-time = ${cfg.aliasDeleteTime}
        enable-upload-notification = ${str cfg.enableMail}
      }

      web {
        bind-host = "${cfg.bindHost}"
        bind-port = ${str cfg.bindPort}
        app-name = "${cfg.appName}"
        baseurl = "${cfg.baseUrl}"
        welcome-message = """${cfg.welcomeMessage}"""
        mail {
          enable = ${str cfg.enableMail}
          default-language = "${cfg.defaultLanguage}"
        }
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

      chunkSize = mkOption {
        type = types.str;
        default = "256K";
        description = "The size of a chunk for chunked uploading.";
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

      welcomeMessage = mkOption {
        default = "";
        description = "A welcome message displayed at the login page. Can be markdown.";
      };

      extraConfig = mkOption {
        default = "";
        description = "More configuration that is appended";
      };

      enableMail = mkOption {
        default = false;
        description = "Enable mail notifications";
      };

      defaultLanguage = mkOption {
        default = "en";
        description = "Language to use for email templates";
      };

      maxValidity = mkOption {
        default = "365 days";
        description = "Maximum validity time for uploads";
      };

      cleanupEnable = mkOption {
        default = true;
        description = "Whether to run periodic removal of outdated uploads";
      };

      cleanupInterval = mkOption {
        default = "30 days";
        description = "Period for running the cleanup job";
      };

      cleanupIntervalAge = mkOption {
        default = "7 days";
        description = "The cleanup job only removes uploads older than this amount";
      };

      aliasDeleteTime = mkOption {
        default = "2 minutes";
        description = "The amount of time an anonymous user can delete his uploads";
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
      # environment = {
      #   "JAVA_TOOL_OPTIONS" = "-Xmx1G";
      # };
      script = ''
        ${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh ${user} -c "cd ${cfg.dataDir} && ${pkgs.sharry}/bin/sharry-server ${sharryConf}"
      '';
    };
  };
}

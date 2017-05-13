{config, lib, pkgs, ...}:

with lib;
let
  cfg = config.services.sharrydemo;
  str = e: if (builtins.typeOf e) == "bool" then (if e then "true" else "false") else (builtins.toString e);
  user = "sharry";
  sharryConf = pkgs.writeText "sharrydemo.conf" ''
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
        mail {
          enable = ${str cfg.enableMail}
        }
      }
      authc.enable = ${str cfg.authenticationEnabled}

      ${cfg.extraConfig}
    }
  '';
in {

  ## interface
  options = {
    services.sharrydemo = {
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
        default = "jdbc:h2:./sharrydemo-db.h2";
        description = "The JDBC database url.";
      };

      logConfigFile = mkOption {
        default = "";
        description = "An optional logback configuration file";
      };

      appName = mkOption {
        default = "Sharry Demo";
        description = "The application name in the top left.";
      };

      baseUrl = mkOption {
        default = "http://localhost:9090/";
        description = "The base url used to construct links. Must end with a slash!";
      };

      simultaneousUploads = mkOption {
        default = 1;
        description = "Number of simultaneous uploads";
      };

      maxFiles = mkOption {
        default = 5;
        description = "Maximum number of files to upload at once";
      };

      maxFileSize = mkOption {
        default = "500K";
        description = "Maximum size of the files to be uploaded, suffixes: M or G";
      };

      authenticationEnabled = mkOption {
        default = false;
        description = "Enable authentication or not";
      };

      extraConfig = mkOption {
        default = "";
        description = "More configuration that is appended";
      };

      enableMail = mkOption {
        default = false;
        description = "Enable mail notifications";
      };

      maxValidity = mkOption {
        default = "12 hours";
        description = "Maximum validity time for uploads";
      };

      cleanupEnable = mkOption {
        default = true;
        description = "Whether to run periodic removal of outdated uploads";
      };

      cleanupInterval = mkOption {
        default = "8 hours";
        description = "Period for running the cleanup job";
      };

      cleanupIntervalAge = mkOption {
        default = "2 minutes";
        description = "The cleanup job only removes uploads older than this amount";
      };

      aliasDeleteTime = mkOption {
        default = "2 minutes";
        description = "The amount of time an anonymous user can delete his uploads";
      };

      dataDir = mkOption {
        default = "/var/data/sharrydemo";
        description = ''
          A data directory used for the H2 database. Note that
          you should use a relative path for jdbcUrl then or leave the default.
        '';
      };
    };
  };

  ## implementation
  config = mkIf cfg.enable {
    systemd.services.sharrydemo = {
      description = "sharrydemo";
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

{config, lib, pkgs, ...}:

with lib;
let
  cfg = config.services.fileshelter;
  str = e: if (builtins.typeOf e) == "bool" then (if e then "true" else "false") else (builtins.toString e);
  user = "fileshelter";
  fileshelterConf = pkgs.writeText "fileshelter.conf" ''
    # Fileshelter Sample configuration file

    # Working directory (must have write privileges)
    working-dir = "${cfg.dataDir}";

    # Max validity duration for a share, in days. Must be greater than 0
    max-validity-days = ${str cfg.maxValidityDays};

    # Max number of downloads for a share. 0 means unlimited
    max-validity-hits = ${str cfg.maxValidityHits};
    # Proposed number of downloads for a share
    default-validity-hits = ${str cfg.defaultValidityHits};

    # Maximum size of the files to be uploaded, in megabytes
    max-file-size = ${str cfg.maxFileSize};

    # Listen port/addr of the web server
    listen-port = ${str cfg.httpPort};
    listen-addr = "${cfg.bindHost}";
    behind-reverse-proxy = ${str cfg.behindReverseProxy};

    # If enabled, these files have to exist and have correct permissions
    tls-enable = false;
    tls-cert = "${cfg.dataDir}/cert.pem";
    tls-key = "${cfg.dataDir}/privkey.pem";
    tls-dh = "${cfg.dataDir}/dh2048.pem";

    # Application settings
    app-name = "${cfg.appName}";

    # ToS settings
    tos-org = "${cfg.tosOrg}";
    tos-url = "${cfg.tosUrl}";
    tos-support-email = "${cfg.tosSupportEmail}";

    # Path to the resources used by the web interface
    docroot = "${cfg.dataDir}/docroot/;/resources,/css,/images,/favicon.ico";
    approot = "${cfg.dataDir}/approot";

    # Bcrypt count parameter used to hash passwords
    bcrypt-count = 12;
  '';
in {

  ## interface
  options = {
    services.fileshelter = {
      enable = mkOption {
        default = false;
        description = "Whether to enable fileshelter.";
      };

      dataDir = mkOption {
        default = "/var/data/fileshelter";
        description = "The data and working directory for fileshelter.";
      };

      bindHost = mkOption {
        default = "localhost";
        description = "The hostname/ip to bind to";
      };

      httpPort = mkOption {
        default = 5091;
        description = "The port for the http connector. A number &lt;= 0 disables http.";
      };

      appName = mkOption {
        default = "FileShelter";
        description = "The application name in the top left.";
      };

      behindReverseProxy = mkOption {
        default = false;
        description = "Whether fileshelter runs behind a reverse proxy";
      };

      maxValidityDays = mkOption {
        default = 100;
        description = "Max validity duration for a share, in days. Must be greater than 0";
      };

      maxValidityHits = mkOption {
        default = 100;
        description = "Max number of downloads for a share. 0 means unlimited";
      };

      defaultValidityHits = mkOption {
        default = 30;
        description = "Proposed number of downloads for a share";
      };

      maxFileSize = mkOption {
        default = 100;
        description = "Maximum size of the files to be uploaded, in megabytes";
      };

      tosOrg = mkOption {
        default = "**[ORG]**";
        description = "Organisation filled into the TOS template.";
      };

      tosUrl = mkOption {
        default = "**[DEPLOY_URL]**/tos";
        description = "A url for the terms-of-service.";
      };

      tosSupportEmail = mkOption {
        default = "***[SUPPORT EMAIL ADDRESS]***";
        description = "Email address for getting support.";
      };
    };
  };

  ## implementation
  config = mkIf cfg.enable {
    users.extraGroups = singleton {
      name = user;
      gid = config.ids.gids.fileshelter;
    };

    users.extraUsers = singleton {
      name = user;
      uid = config.ids.uids.fileshelter;
      extraGroups = ["fileshelter"];
      description = "fileshelter daemon user.";
    };

    systemd.services.fileshelter = {
      description = "fileshelter";
      after = [ "networking.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        if [ ! -d "${cfg.dataDir}" ]; then
          mkdir -p ${cfg.dataDir}
          chown fileshelter:fileshelter ${cfg.dataDir}
        fi
        ln -nsf ${pkgs.fileshelter}/share/fileshelter/* ${cfg.dataDir} #*/
      '';

      script = ''
        ${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh ${user} -c "cd ${cfg.dataDir} && ${pkgs.fileshelter}/bin/fileshelter ${fileshelterConf}"
      '';
    };
  };
}

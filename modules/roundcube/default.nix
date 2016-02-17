{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.roundcube;
  nginx = config.services.nginx;
  rc = "${pkgs.roundcube}/roundcube";
in {

### interface

  options = {
    services.roundcube = {

      enable = mkOption {
        default = false;
        description = "Enable roundcube, by providing it to nginx.";
      };

      smtpServer = mkOption {
        default = "localhost";
        description = "The smtp server name";
      };

      smtpPort = mkOption {
        default = 25;
        description = "The smtp port";
      };

      baseDir = mkOption {
        default = "/var/run/roundcube";
        description = "The directory used to run roundcube";
      };

      dataDir = mkOption {
        default = "/var/data/roundcube";
        description = "The directory to store roundcube data (i.e. sqlite db file)";
      };

      productName = mkOption {
        default = "Roundcube Webmail";
        description = "A short string displayed on the login page.";
      };

      supportUrl = mkOption {
        default = "/";
        description = "Where a user can get support for this roundcube installation";
      };

      nginxEnable = mkOption {
        default = false;
        description = ''
          If true, add a nginx http snippet to server roundcube. Please
          see the other options starting with 'nginx'.
        '';
      };

      nginxListen = mkOption {
        default = "80";
        description = "The <literal>listen</literal> directive for roundcube.";
      };

      nginxServerName = mkOption {
        default = null;
        description = "The <literal>server_name</literal> directive for roundcube.";
      };

      nginxFastCgiPass = mkOption {
        default = "unix:/run/fastcgi.socket";
        description = "FastCgi socket connection.";
      };
    };
  };


### implementation

  config = mkIf config.services.roundcube.enable {

    environment.systemPackages = [ pkgs.php pkgs.roundcube ];

    services.nginx.httpConfig = mkIf cfg.nginxEnable ''
      server {
         listen ${cfg.nginxListen};
         ${if (cfg.nginxServerName != null) then "server_name ${cfg.nginxServerName};" else ""}
         root ${cfg.baseDir};
         index index.php;
         location / {
           try_files $uri $uri/ /index.php;
         }
         location ~ \.php$ {
           fastcgi_pass ${cfg.nginxFastCgiPass};
           fastcgi_index index.php;
           include ${pkgs.nginx}/conf/fastcgi_params;
           include ${pkgs.nginx}/conf/fastcgi.conf;
         }
      }
    '';

    system.activationScripts = {
      roundcube = ''
        mkdir -p ${cfg.baseDir}/{temp,logs,config}

        ln -snf ${rc}/plugins ${cfg.baseDir}/plugins
        ln -snf ${rc}/program ${cfg.baseDir}/program
        ln -snf ${rc}/skins ${cfg.baseDir}/skins
        ln -snf ${rc}/.htaccess ${cfg.baseDir}/.htaccess
        ln -snf ${rc}/composer.json-dist ${cfg.baseDir}/composer.json-dist
        ln -snf ${rc}/index.php ${cfg.baseDir}/index.php
        ln -snf ${rc}/robots.txt ${cfg.baseDir}/robots.txt
        cp ${rc}/config/* ${cfg.baseDir}/config/
        # /**/

        if ! [ -f ${cfg.dataDir}/rc-data.db ]; then
           mkdir -p ${cfg.dataDir}
           ${pkgs.sqlite}/bin/sqlite3 ${cfg.dataDir}/rc-data.db < ${rc}/SQL/sqlite.initial.sql
           chown -R ${nginx.user}:${nginx.group} ${cfg.dataDir}
        fi

        chown -R ${nginx.user}:${nginx.group} ${cfg.baseDir}/{temp,logs}

        RC_KEY=
        if ! [ -r ${cfg.dataDir}/key ]; then
            tr -dc "[:alnum:]" < /dev/urandom | head -c24 > ${cfg.dataDir}/key
        fi
        RC_KEY=$(cat ${cfg.dataDir}/key)

        cat > ${cfg.baseDir}/config/config.inc.php <<- EOF
        <?php

        \$config = array();
        \$config['db_dsnw'] = 'sqlite:///${cfg.dataDir}/rc-data.db';
        \$config['default_host'] = 'localhost';
        \$config['imap_auth_type'] = 'LOGIN';
        \$config['imap_cache'] = 'db';
        \$config['smtp_server'] = '${cfg.smtpServer}';
        \$config['smtp_port'] = ${builtins.toString cfg.smtpPort};
        \$config['product_name'] = '${cfg.productName}';
        \$config['des_key'] = '$RC_KEY';
        \$config['plugins'] = array('archive', 'zipdownload');
        \$config['skin'] = 'larry';
        \$config['debug_level'] = 1;
        \$config['log_driver'] = 'syslog';
        \$config['enable_installer'] = false;
        \$config['support_url'] = '${cfg.supportUrl}';
        \$config['language'] = 'de_DE';
        \$config['timezone'] = "Europe/Berlin";
        \$config['prefer_html'] = false;
        \$config['min_refresh_interval'] = 600;
        EOF

      '';
    };
  };
}

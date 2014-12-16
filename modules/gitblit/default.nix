{config, lib, pkgs, ...}:

with lib;
let
  cfg = config.services.gitblit;
  str = e: if (builtins.typeOf e) == "bool" then (if e then "true" else "false") else (builtins.toString e);
  gitblitUser = "gitblit";

in {

  ## interface
  options = {
    services.gitblit = {
      enable = mkOption {
        default = false;
        description = "Whether to enable gitblit.";
      };

      baseDir = mkOption {
        default = "/var/run/gitblit";
        description = "The base directory for running gitblit.";
      };

      dataDir = mkOption {
        default = "/var/data/gitblit";
        description = "The data directory for gitblit. If relative, it is relative to <literal>baseDir</literal>.";
      };

      repositoriesDir = mkOption {
        default = "${cfg.dataDir}/git";
        description = "The directory containing the git repositories. If relative, it is relative to <literal>dataDir</literal>.";
      };

      httpPort = mkOption {
        default = 9110;
        description = "The port for the http connector. A number &lt;= 0 disables http.";
      };

      httpsPort = mkOption {
        default = 0;
        description = "The port for the https connector. A number &lt;= 0 disables https.";
      };

      gitPort = mkOption {
        default = 9418;
        description = "The port for the git daemon. A number &lt;= 0 disables git daemon.";
      };

      sshPort = mkOption {
        default = 29418;
        description = "The port for the ssh daemon. A number &lt;= 0 disables ssh.";
      };

      ticketBackend = mkOption {
        default = "com.gitblit.tickets.FileTicketService";
        description = ''
          The ticket storage backend to use. See http://gitblit.org/tickets_setup.html for
          other options. An empty string disables the ticket feature.
        '';
      };

      httpurlRealm = mkOption {
        default = null;
        description = "The url pattern used with <literal>realm.httpurl.urlPattern</literal>.";
      };

      httpurlPost = mkOption {
        default = false;
        description = "Whether to authenticate via post requests";
      };

      canonicalUrl = mkOption {
        default = "";
        description = "The canonical url of running gitblit instance.";
      };

      enableMirroring = mkOption {
        default = true;
        description = "Enable mirroring git repositories with gitblit.";
      };

      mirrorPeriod = mkOption {
        default = "300 mins";
        description = "The period between update checks for mirrored repositories.";
      };

      mailServer = mkOption {
        default = "";
        description = "The smtp server used by gitblit";
      };

      mailPort = mkOption {
        default = 25;
        description = "The smtp port.";
      };

      mailStartTLS = mkOption {
        default = false;
        description = "Whether to use StartTLS with smtp.";
      };

      mailSmtps = mkOption {
        default = false;
        description = "Whether to use smtps protocol.";
      };

      mailUsername = mkOption {
        default = "";
        description = "Username to use for smtp authentication.";
      };

      mailPassword = mkOption {
        default = "";
        description = "Password to use for smtp authentication.";
      };

      mailFromAddress = mkOption {
        default = "";
        description = "From address for generated mails.";
      };

      mailAdminAddresses = mkOption {
        default = [];
        description = "List of email addresses for the gitblit admins.";
      };
    };
  };

  ## implementation
  config = mkIf config.services.gitblit.enable {
    users.extraGroups = singleton {
      name = "gitblit";
      gid = config.ids.gids.gitblit;
    };

    users.extraUsers = singleton {
      name = gitblitUser;
      uid = config.ids.uids.gitblit;
      extraGroups = ["gitblit"];
      description = "Gitblit daemon user.";
    };

    environment.systemPackages = [ pkgs.gitblit ];

    systemd.services.gitblit = {
      description = "Gitblit";
      after = [ "networking.target" ];

      preStart = ''
        mkdir -p ${cfg.baseDir}
        cd ${cfg.baseDir}
        if [ ! -d ${cfg.dataDir} ]; then
           mkdir -p ${cfg.dataDir}
           cp -R ${pkgs.gitblit}/data/* ${cfg.dataDir}/
           # /**/
           chown -R ${gitblitUser}:gitblit ${cfg.dataDir}/
           find ${cfg.dataDir}/ -type d -exec chmod 755 {} \;
        fi
        sed -i 's,^tickets.service.*,tickets.service=${cfg.ticketBackend},' ${cfg.dataDir}/gitblit.properties
        sed -i 's,^realm.authenticationProviders.*,realm.authenticationProviders = httpurl,' ${cfg.dataDir}/gitblit.properties
        sed -i 's,^web.canonicalUrl.*,web.canonicalUrl = ${cfg.canonicalUrl},' ${cfg.dataDir}/gitblit.properties
        sed -i 's,^git.enableMirroring.*,git.enableMirroring = ${str cfg.enableMirroring},' ${cfg.dataDir}/gitblit.properties
        sed -i 's,^git.mirrorPeriod.*,git.mirrorPeriod = ${cfg.mirrorPeriod},' ${cfg.dataDir}/gitblit.properties
        sed -i 's,^mail.server.*,mail.server = ${cfg.mailServer},' ${cfg.dataDir}/gitblit.properties
        sed -i 's,^mail.port.*,mail.port = ${builtins.toString cfg.mailPort},' ${cfg.dataDir}/gitblit.properties
        sed -i 's,^mail.smtps.*,mail.smtps = ${str cfg.mailSmtps},' ${cfg.dataDir}/gitblit.properties
        sed -i 's,^mail.starttls.*,mail.starttls = ${str cfg.mailStartTLS},' ${cfg.dataDir}/gitblit.properties
        sed -i 's,^mail.username.*,mail.username = ${cfg.mailUsername},' ${cfg.dataDir}/gitblit.properties
        sed -i 's,^mail.password.*,mail.password = ${cfg.mailPassword},' ${cfg.dataDir}/gitblit.properties
        sed -i 's,^mail.fromAddress.*,mail.fromAddress = ${cfg.mailFromAddress},' ${cfg.dataDir}/gitblit.properties
        sed -i 's,^mail.adminAddresses.*,mail.adminAddresses = ${concatStringsSep " " cfg.mailAdminAddresses},' ${cfg.dataDir}/gitblit.properties

        ${if (cfg.httpurlRealm != null) then ''
        sed -i 's,^realm.httpurl.*,,' ${cfg.dataDir}/gitblit.properties
        echo "realm.httpurl.urlPattern = ${cfg.httpurlRealm}" >> ${cfg.dataDir}/gitblit.properties
        echo "realm.httpurl.usePost = ${if (cfg.httpurlPost) then "true" else "false"}" >> ${cfg.dataDir}/gitblit.properties
        '' else ""}
        ln -snf ${pkgs.gitblit}/ext ${cfg.baseDir}/ext
        ln -snf ${pkgs.gitblit}/docs ${cfg.baseDir}/docs
        cp ${pkgs.gitblit}/gitblit.jar ${cfg.baseDir}/
      '';

      script = ''
        ${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh ${gitblitUser} -c "cd ${cfg.baseDir} && ${pkgs.jdk}/bin/java -jar gitblit.jar --baseFolder ${cfg.dataDir} --dailyLogFile --httpPort ${str cfg.httpPort} --httpsPort ${str cfg.httpsPort} --sshPort ${str cfg.sshPort} --gitPort ${str cfg.gitPort} --repositoriesFolder ${cfg.repositoriesDir} "
      '';
    };
  };
}

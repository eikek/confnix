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
        default = "/var/gitblit";
        description = "The base directory for running gitblit.";
      };

      dataDir = mkOption {
        default = "data";
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
        description = "The ticket storage backend to use. See http://gitblit.org/tickets_setup.html for other options. Set empty string to disable the ticket feature.";
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

    jobs.gitblit = {
      description = "Gitblit";
      startOn = "started networking";
      daemonType = "daemon";

      preStart = ''
        cd ${cfg.baseDir}
        if [ ! -d ${cfg.dataDir} ]; then
           mkdir -p ${cfg.dataDir}
           cp -R ${pkgs.gitblit}/data ${cfg.dataDir}/
           chown -R ${gitblitUser}:gitblit ${cfg.dataDir}/
           find ${cfg.dataDir}/ -type d -exec chmod 755 {} \;
        fi
        sed -i 's/^tickets.service.*/tickets.service=${cfg.ticketBackend}/' ${cfg.dataDir}/gitblit.properties
        ln -snf ${pkgs.gitblit}/ext ${cfg.baseDir}/ext
        ln -snf ${pkgs.gitblit}/docs ${cfg.baseDir}/docs
        cp ${pkgs.gitblit}/{env-vars,gitblit.jar} ${cfg.baseDir}/
      '';

      exec = ''
        ${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh ${gitblitUser} -c "cd ${cfg.baseDir} && ${pkgs.jdk}/bin/java -jar gitblit.jar --baseFolder ${cfg.dataDir} --dailyLogFile --httpPort ${str cfg.httpPort} --httpsPort ${str cfg.httpsPort} --sshPort ${str cfg.sshPort} --gitPort ${str cfg.gitPort} --repositoriesFolder ${cfg.repositoriesDir} &"
      '';
    };
  };
}

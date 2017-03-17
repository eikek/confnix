{config, lib, pkgs, ...}:

with lib;
let
  cfg = config.services.gitbucket;
  str = e: if (builtins.typeOf e) == "bool" then (if e then "true" else "false") else (builtins.toString e);
  gitbucketUser = "gitbucket";
in {

  ## interface
  options = {
    services.gitbucket = {
      enable = mkOption {
        default = false;
        description = "Whether to enable gitbucket.";
      };

      dataDir = mkOption {
        default = "/var/data/gitbucket";
        description = "The data directory for gitbucket. If relative, it is relative to <literal>baseDir</literal>.";
      };

      bindHost = mkOption {
        default = "localhost";
        description = "The hostname/ip to bind to";
      };

      httpPort = mkOption {
        default = 9110;
        description = "The port for the http connector. A number &lt;= 0 disables http.";
      };

      contextPath = mkOption {
        default = "/";
        description = "The context-path prefix of running gitbucket instance.";
      };

      baseUrlHost = mkOption {
        default = "localhost";
        description = "The public hostname";
      };

      baseUrl = mkOption {
        default = "http://${cfg.baseUrlHost}:${str cfg.httpPort}";
        description = "The url base to use";
      };

      useGravatar = mkOption {
        default = true;
        description = "Whether to use the gravartar service";
      };

      useSMTP = mkOption {
        default = false;
        description = "Whether to enable mail sending";
      };

      smtpHost = mkOption {
        default = "localhost";
        description = "The smtp host to use";
      };

      smtpPort = mkOption {
        default = 25;
        description = "SMTP Port to use";
      };

      allowOverrideSettings = mkOption {
        default = false;
        description = ''Whether to allow changing settings in
          the webapp. If false, settings can only be changed
          from nix files. This is achieved by keeping permissions
           to root.'';
      };
    };
  };

  ## implementation
  config = mkIf cfg.enable {
    users.extraGroups = singleton {
      name = gitbucketUser;
      gid = config.ids.gids.gitbucket;
    };

    users.extraUsers = singleton {
      name = gitbucketUser;
      uid = config.ids.uids.gitbucket;
      extraGroups = ["gitbucket"];
      description = "gitbucket daemon user.";
    };

    systemd.services.gitbucket = {
      description = "gitbucket";
      after = [ "networking.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        if [ ! -d "${cfg.dataDir}" ]; then
          mkdir -p ${cfg.dataDir}
          chown gitbucket:gitbucket ${cfg.dataDir}
        fi
        CFG_FILE=${cfg.dataDir}/gitbucket.conf
        if [ ! -e $CFG_FILE ] || ([ -e $CFG_FILE.md5 ] && [[ $(cat $CFG_FILE | md5sum) = $(cat $CFG_FILE.md5) ]]); then
          echo "ssh=true" > $CFG_FILE
          echo "ssh.host=${cfg.baseUrlHost}" >> $CFG_FILE
          echo "ssh.port=29418" >> $CFG_FILE
          echo "base_url=${cfg.baseUrl}" >> $CFG_FILE
          echo "gravatar=${str cfg.useGravatar}" >> $CFG_FILE
          echo "useSMTP=${str cfg.useSMTP}" >> $CFG_FILE
          echo "smtp.host=${cfg.smtpHost}" >> $CFG_FILE
          echo "smtp.port=${str cfg.smtpPort}" >> $CFG_FILE
          cat $CFG_FILE|md5sum> $CFG_FILE.md5
          ${if (cfg.allowOverrideSettings) then "chown gitbucket:gitbucket $CFG_FILE*" else "chown root:root $CFG_FILE*"}
        fi
      '';

      script = ''
        ${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh ${gitbucketUser} -c "cd ${cfg.dataDir} && ${pkgs.gitbucket}/bin/gitbucket --host=${cfg.bindHost} --port=${str cfg.httpPort} --prefix=${cfg.contextPath} --gitbucket.home=${cfg.dataDir} "
      '';
    };
  };
}

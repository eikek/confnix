{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.gitea;
  configFile = pkgs.writeText "app.ini" ''
    APP_NAME = ${cfg.appName}
    RUN_USER = ${cfg.user}
    RUN_MODE = prod

    [database]
    DB_TYPE = ${cfg.database.type}
    HOST = ${cfg.database.host}:${toString cfg.database.port}
    NAME = ${cfg.database.name}
    USER = ${cfg.database.user}
    PASSWD = ${cfg.database.password}
    PATH = ${cfg.database.path}

    [repository]
    ROOT = ${cfg.repositoryRoot}

    [server]
    DOMAIN = ${cfg.domain}
    HTTP_ADDR = ${cfg.httpAddress}
    HTTP_PORT = ${toString cfg.httpPort}
    ROOT_URL = ${cfg.rootUrl}

    [security]
    SECRET_KEY = #secretkey#
    INSTALL_LOCK = true

    [service]
    DISABLE_REGISTRATION = ${if (cfg.disableRegistration) then "true" else "false"}

    ${cfg.extraConfig}
  '';
in

{
  options = {
    services.gitea = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "Enable Gitea Service.";
      };

      useWizard = mkOption {
        default = false;
        type = types.bool;
        description = "Do not generate a configuration and use Gitea' installation wizard instead. The first registered user will be administrator.";
      };

      stateDir = mkOption {
        default = "/var/data/gitea";
        type = types.str;
        description = "Gitea data directory.";
      };

      user = mkOption {
        type = types.str;
        default = "gitea";
        description = "User account under which Gitea runs.";
      };

      group = mkOption {
        type = types.str;
        default = "gitea";
        description = "Group account under which Gitea runs.";
      };

      database = {
        type = mkOption {
          type = types.enum [ "sqlite3" "mysql" "postgres" ];
          example = "mysql";
          default = "sqlite3";
          description = "Database engine to use.";
        };

        host = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Database host address.";
        };

        port = mkOption {
          type = types.int;
          default = 3306;
          description = "Database host port.";
        };

        name = mkOption {
          type = types.str;
          default = "gitea";
          description = "Database name.";
        };

        user = mkOption {
          type = types.str;
          default = "gitea";
          description = "Database user.";
        };

        password = mkOption {
          type = types.str;
          default = "";
          description = "Database password.";
        };

        path = mkOption {
          type = types.str;
          default = "${cfg.stateDir}/data/gitea.db";
          description = "Path to the sqlite3 database file.";
        };
      };

      appName = mkOption {
        type = types.str;
        default = "Gitea: Git Service";
        description = "Application name.";
      };

      repositoryRoot = mkOption {
        type = types.str;
        default = "${cfg.stateDir}/repositories";
        description = "Path to the git repositories.";
      };

      domain = mkOption {
        type = types.str;
        default = "localhost";
        description = "Domain name of your server.";
      };

      rootUrl = mkOption {
        type = types.str;
        default = "http://localhost:3000/";
        description = "Full public URL of Gitea server.";
      };

      httpAddress = mkOption {
        type = types.str;
        default = "0.0.0.0";
        description = "HTTP listen address.";
      };

      httpPort = mkOption {
        type = types.int;
        default = 3000;
        description = "HTTP listen port.";
      };

      disableRegistration = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to disable registration";
      };

      extraConfig = mkOption {
        type = types.str;
        default = "";
        description = "Configuration lines appended to the generated Gitea configuration file.";
      };
    };
  };

  config = mkIf cfg.enable {

    systemd.services.gitea = {
      description = "Gitea (Go Git Service)";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.gitea.bin ];

      preStart = ''
        # copy custom configuration and generate a random secret key if needed
        ${optionalString (cfg.useWizard == false) ''
          mkdir -p ${cfg.stateDir}/custom/conf
          cp -f ${configFile} ${cfg.stateDir}/custom/conf/app.ini
          KEY=$(head -c 256 /dev/urandom | tr -dc A-Za-z0-9)
          sed -i "s,#secretkey#,$KEY,g" ${cfg.stateDir}/custom/conf/app.ini
        ''}

        ln -nsf ${pkgs.gitea.data}/options ${cfg.stateDir}/options

        mkdir -p ${cfg.repositoryRoot}
        # update all hooks' binary paths
        HOOKS=$(find ${cfg.repositoryRoot} -mindepth 4 -maxdepth 4 -type f -wholename "*git/hooks/*")
        if [ "$HOOKS" ]
        then
          sed -ri 's,/nix/store/[a-z0-9.-]+/bin/gitea,${pkgs.gitea.bin}/bin/gitea,g' $HOOKS
          sed -ri 's,/nix/store/[a-z0-9.-]+/bin/env,${pkgs.coreutils}/bin/env,g' $HOOKS
          sed -ri 's,/nix/store/[a-z0-9.-]+/bin/bash,${pkgs.bash}/bin/bash,g' $HOOKS
          sed -ri 's,/nix/store/[a-z0-9.-]+/bin/perl,${pkgs.perl}/bin/perl,g' $HOOKS
        fi
      '';

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.stateDir;
        ExecStart = "${pkgs.gitea.bin}/bin/gitea web";
        Restart = "always";
      };

      environment = {
        USER = cfg.user;
        HOME = cfg.stateDir;
        GITEA_WORK_DIR = cfg.stateDir;
      };
    };

    users = {
      extraUsers.${cfg.user} = {
        description = "Go Git Service";
        uid = config.ids.uids.gitea;
        group = "gitea";
        home = cfg.stateDir;
        createHome = true;
        shell = pkgs.bash;
      };
      extraGroups.gitea.gid = config.ids.gids.gitea;
    };
  };
}
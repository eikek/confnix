{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.attentive;
  jdbcUrl = if cfg.jdbc.url == null then "jdbc:sqlite:${cfg.jdbc.dataDir}/attentive-sqlite.db" else cfg.jdbc.url;
  configFile = pkgs.writeText "attentive.conf" ''
    attentive {
      app-name = "${cfg.appName}"
      bind {
        host = "${cfg.bindHost}"
        port = ${toString cfg.bindPort}
      }

      base-url = "${cfg.baseUrl}"

      server-secret = "${cfg.serverSecret}"

      jdbc {
        url = "${jdbcUrl}"
        user = "${cfg.jdbc.user}"
        password = "${cfg.jdbc.password}"
        driver = "${cfg.jdbc.driver}"
        poolsize = ${toString cfg.jdbc.poolSize}
      }

      auth {
        token-valid = ${cfg.auth.tokenValid}
        session-valid = ${cfg.auth.sessionValid}
      }

      registration {
        mode = "${cfg.registration.mode}"
        invitation-key = "${cfg.registration.invitationKey}"
        invitation-valid = ${cfg.registration.invitationValid}
      }

      stats {
        cache-time = ${cfg.stats.cacheTime}
      }
    }
  '';
in
{

  ## interface
  options = {
    services.attentive = {
      enable = mkOption {
        default = false;
        description = "Whether to enable attentive.";
      };

      appName = mkOption {
        type = types.str;
        default = "Attentive";
        description = "The name used in the web ui and in notification mails.";
      };

      bindHost = mkOption {
        type = types.str;
        default = "localhost";
        description = "The address to bind the webserver";
      };
      bindPort = mkOption {
        type = types.int;
        default = 8771;
        description = "The port to bind the web server";
      };

      baseUrl = mkOption {
        type = types.str;
        default = "http://localhost:8771";
        description = "The base url where attentive is deployed.";
      };

      serverSecret = mkOption {
        type = types.str;
        default = "";
        description = ''
          A secret used to encrypt cookie data. If empty a random value is
          generated at application start.
        '';
      };

      jdbc = mkOption {
        type = types.submodule ({
          options = {
            url = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = ''
                The URL to the database. By default a file-based database is
                used. It should also work with mariadb and postgresql.

                Examples:
                   "jdbc:mariadb://192.168.1.172:3306/attentive"
                   "jdbc:postgresql://localhost:5432/attentive"
                   "jdbc:h2:./target/attentive.db"
                   "jdbc:sqlite:./target/attentive-sqlite.db"

                By default, it is set to `null`. This results in a SQLite database
                that is located in the jdbc.dataDir directory. If this url
                is set to some value, the `dataDir` property is discarded.
              '';
            };
            dataDir = mkOption {
              type = types.str;
              default = "/var/data/attentive";
              description = ''
                If jdbc.url is null, then a SQLite database URL is
                created using this directory. If the jdbc.url property
                is set, then this value is discarded.
              '';
            };
            user = mkOption {
              type = types.str;
              default = "sa";
              description = "The user name to connect to the database.";
            };
            password = mkOption {
              type = types.str;
              default = "";
              description = "The password to connect to the database.";
            };
            driver = mkOption {
              type = types.str;
              default = "org.sqlite.JDBC";
              description = ''
                The driver class name.
                - H2: org.h2.Driver
                - MariaDB: org.mariadb.jdbc.Driver
                - PostgreSQL: org.postgresql.Driver
                - SQLite: org.sqlite.JDBC
              '';
            };
            poolSize = mkOption {
              type = types.int;
              default = 10;
              description = "The database pool size.";
            };
          };
        });
        default = {
          url = null;
          dataDir = "/var/data/attentive";
          user = "sa";
          password = "";
          driver = "org.sqlite.JDBC";
          poolSize = 10;
        };
        description = "Database connection settings";
      };

      auth = mkOption {
        type = types.submodule ({
          options = {
            tokenValid = mkOption {
              type = types.str;
              default = "3 minutes";
              description = "The time a login is valid";
            };
            sessionValid = mkOption {
              type = types.str;
              default = "6 hours";
              description = "The time the session is valid.";
            };
          };
        });
        default = {
          tokenValid = "3 minutes";
          sessionValid = "6 hours";
        };
        description = "Authentication settings.";
      };

      registration = mkOption {
        type = types.submodule ({
          options = {
            mode = mkOption {
              type = types.str;
              default = "closed";
              description = ''
                Registration of new accounts may be one of:
                - open: Everybody can create new accounts.
                - closed: No one can create new accounts; registration is disabled.
                - invite: Registration is possible only with the correct invitation key.
              '';
            };
            invitationKey = mkOption {
              type = types.str;
              default = "";
              description = ''
                The "super" invitation password used to generate new invitations.
                If empty, generating invitation keys is not possible.
              '';
            };
            invitationValid = mkOption {
              type = types.str;
              default = "6 days";
              description = "How long a generated invitation key is valid.";
            };
          };
        });
        default = {
          mode = "closed";
          invitationKey = "";
          invitationValid = "6 days";
        };
        description = "Registration settings";
      };

      stats = mkOption {
        type = types.submodule ({
          options = {
            cacheTime = mkOption {
              type = types.str;
              default = "3 minutes";
              description = ''
                How long statistic values are cached. Longer times results in
                less db queries but more stale values.
              '';
            };
          };
        });
        default = {
          cacheTime = "3 minutes";
        };
        description = "Stats settings.";
      };
    };
  };

  ## implementation
  config = mkIf config.services.attentive.enable {
    users.extraGroups = singleton {
      name = "attentive";
      gid = config.ids.gids.attentive;
    };

    users.extraUsers = singleton {
      name = "attentive";
      uid = config.ids.uids.attentive;
      extraGroups = [ "attentive" ];
      description = "Attentive daemon user.";
    };

    systemd.services.attentive = {
      description = "Attentive server";
      after = [ "networking.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.gawk ];
      preStart = ''
        ${if cfg.jdbc.url == null then "mkdir -p ${cfg.jdbc.dataDir} && chown attentive:attentive ${cfg.jdbc.dataDir}" else ""}
      '';

      script = "${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh attentive -c \"${pkgs.attentive}/bin/attentive ${configFile}\"";
    };
  };
}

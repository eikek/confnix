{config, lib, pkgs, ...}:

with lib;
let
  cfg = config.services.pickup;
  user = if cfg.runAs == null then "pickup" else cfg.runAs;
  configFile = pkgs.writeText "pickup.conf" ''
    pickup {
      transfer {
        working-dir = "${cfg.baseDir}"
        gpg-cmd = "${cfg.gpgPkg}/bin/gpg"
        duplicity-cmd = "${cfg.duplicityPkg}/bin/duplicity"
        keyscan-cmd = "${cfg.sshPkg}/bin/ssh-keyscan"

        # The arguments to duplicity when doing backups.
        #
        # The url and options for transport are added by pickup.
        backup-args = ${builtins.toJSON cfg.backupArgs}

        # After each backup run, a cleanup run is performed to not grow
        # unbounded.
        cleanup-args = ${builtins.toJSON cfg.cleanupArgs}

        # Additional arguments passed to restore command.
        restore-args = ${builtins.toJSON cfg.restoreArgs}

        personal {
          enable = ${if cfg.personalSsh.enable then "true" else "false"}

          # The root directory to this SFTP endpoint. This is also the
          # directory that is backed up. Restores are also copied into
          # this folder.
          root = ${cfg.personalSsh.root}

          # The host and port to bind the sftp server to.
          host = "${cfg.personalSsh.bindHost}"
          port = ${toString cfg.personalSsh.bindPort}

          # A default user for logging in.
          default-user = "backup"

          # A connection string exposed to users. The above info specifies
          # where the sftp server binds to. This string is shown to users
          # so that they can connect. This can be different, if for
          # example DNS is used.
          connection-uri = "${cfg.personalSsh.connectionUri}"
        }

        # The "remote" sftp endpoint. This is where other peers connect
        # and sent their encrypted backup data.
        remote {
          root = ${cfg.remoteSsh.root}
          host = "${cfg.remoteSsh.bindHost}"
          port = ${toString cfg.remoteSsh.bindPort}
          connection-uri = "${cfg.remoteSsh.connectionUri}"
        }

        # SMTP settings used to send notification mails.  This is only
        # necessary to fully supply if you send mails to arbirtrary
        # mailboxes. If, for example, you only need to send to yourself,
        # just add your mail as the `sender` below. It many cases this
        # should work
        smtp {
          host = "${cfg.smtp.host}"
          port = ${toString cfg.smtp.port}
          user = "${cfg.smtp.user}"
          password = "${cfg.smtp.password}"
          start-tls = ${if cfg.smtp.startTls then "true" else "false"}
          use-ssl = ${if cfg.smtp.useSsl then "true" else "false"}
          sender = "${cfg.smtp.sender}"
        }

        # Enable to get notified via email when a backup fails.
        notify-mail {
          enable = ${if cfg.notifyMail.enable then "true" else "false"}
          recipients = ${builtins.toJSON cfg.notifyMail.recipients}
        }
      }
      http {
        app-name = "${cfg.appName}"
        bind {
          host = "${cfg.bindHost}"
          port = ${toString cfg.bindPort}
        }
      }
    }
  '';
in {

  ## interface
  options = {
    services.pickup = {
      enable = mkOption {
        default = false;
        description = "Whether to enable pickup.";
      };

      runAs = mkOption {
        type = types.nullOr types.string;
        default = null;
        description = ''
          The user that runs the pickup server process. If this is
          null, a new user pickup is created. If specified, the user
          must exist.
        '';
      };

      baseDir = mkOption {
        type = types.path;
        default = "/var/data/pickup";
        description = "The folder where pickup stores data.";
      };

      appName = mkOption {
        type = types.string;
        default = "Pickup";
        description = "The name used in the web ui and in notification mails.";
      };

      bindHost = mkOption {
        type = types.string;
        default = "localhost";
        description = "The address to bind the webserver";
      };
      bindPort = mkOption {
        type = types.int;
        default = 8011;
        description = "The port to bind the web server";
      };

      gpgPkg = mkOption {
        type = types.package;
        default = pkgs.gnupg;
        description = "The package providing the gpg command.";
      };
      duplicityPkg = mkOption {
        type = types.package;
        default = pkgs.duplicity;
        description = "The package providing the duplicity command.";
      };
      sshPkg = mkOption {
        type = types.package;
        default = pkgs.openssh;
        description = "The package providing the ssh-keyscan command.";
      };

      backupArgs = mkOption {
        type = types.listOf types.string;
        default = [ "--full-if-older-than" "1M" ];
        description = "Additional arguments to duplicity when running the backup";
      };
      cleanupArgs = mkOption {
        type = types.listOf types.string;
        default = [ "remove-all-but-n-full" "2" ];
        description = "Additional arguments to duplicity when running the cleanup";
      };
      restoreArgs = mkOption {
        type = types.listOf types.string;
        default = [ "-vI" ];
        description = "Additional arguments to duplicity when running the restore";
      };

      personalSsh = mkOption {
        type = types.submodule ({
          options = {
            enable = mkOption {
              type = types.bool;
              default = false;
              description = "Whether to enable the personal sftp endpoint";
            };
            root = mkOption {
              type = types.string;
              default = "${cfg.baseDir}/ssh-personal";
              description = "The root folder of this sftp endpoint";
            };
            bindHost = mkOption {
              type = types.string;
              default = "localhost";
              description = "The address to bind the sftp endpoint";
            };
            bindPort = mkOption {
              type = types.int;
              default = 12021;
              description = "The port to bind the sftp endpoint";
            };
            defaultUser = mkOption {
              type = types.string;
              default = "backup";
              description = "The user for logging into the personal sftp endpoint";
            };
            connectionUri = mkOption {
              type = types.string;
              default = "${cfg.personalSsh.defaultUser}@${cfg.personalSsh.bindHost}:${toString cfg.personalSsh.bindPort}";
              description = "The exposed endpoint url to the personal sftp";
            };
          };
        });
        default = {
          enable = false;
          root = "${cfg.baseDir}/ssh-personal";
          bindHost = "localhost";
          bindPort = 12021;
          defaultUser = "backup";
          connectionUri = "${cfg.personalSsh.defaultUser}@${cfg.personalSsh.bindHost}:${toString cfg.personalSsh.bindPort}";
        };
        description = "Settings for the personal sftp endpoint";
      };
      remoteSsh = mkOption {
        type = types.submodule ({
          options = {
            root = mkOption {
              type = types.string;
              default = "${cfg.baseDir}/ssh-remote";
              description = "The root folder of this sftp endpoint";
            };
            bindHost = mkOption {
              type = types.string;
              default = "localhost";
              description = "The address to bind the sftp endpoint";
            };
            bindPort = mkOption {
              type = types.int;
              default = 24042;
              description = "The port to bind the sftp endpoint";
            };
            connectionUri = mkOption {
              type = types.string;
              default = "${cfg.remoteSsh.bindHost}:${toString cfg.remoteSsh.bindPort}";
              description = "The exposed endpoint url to the personal sftp";
            };
          };
        });
        default = {
          root = "${cfg.baseDir}/ssh-remote";
          bindHost = "localhost";
          bindPort = 24042;
          connectionUri = "${cfg.remoteSsh.bindHost}:${toString cfg.remoteSsh.bindPort}";
        };
        description = "Settings for the remote sftp endpoint.";
      };

      notifyMail = mkOption {
        type = types.submodule ({
          options = {
            enable = mkOption {
              type = types.bool;
              default = false;
              description = "Whether to notify via mail when a backup fails";
            };
            recipients = mkOption {
              type = types.listOf types.string;
              default = [];
              description = "A list of email addresses that receive notifications.";
            };
          };
        });
        default = {
          enable = false;
          recipients = [];
        };
        description = "Settings for mail notify";
      };

      smtp = mkOption {
        type = types.submodule({
          options = {
            host = mkOption {
              type = types.string;
              description = "The smtp host to use for sending notification mails. If empty, the MX host of each recipient is used.";
            };
            port = mkOption {
              type = types.int;
              description = "The smtp port to use for sending notification mails.";
            };
            user = mkOption {
              type = types.string;
              description = "The username to use for authentication on smtp server";
            };
            password = mkOption {
              type = types.string;
              description = "The password to use for authentication on smtp server";
            };
            startTls = mkOption {
              type = types.bool;
              default = false;
              description = "Whether to connect via SartTLS";
            };
            useSsl = mkOption {
              type = types.bool;
              default = false;
              description = "Whether to connect via SSL";
            };
            sender = mkOption {
              type = types.string;
              description = "The sender email address to use.";
            };
          };
        });
        default = {
          host = "";
          port = 0;
          user = "";
          password = "";
          useSsl = false;
          startTls = false;
          sender = "noreply@localhost";
        };
        description = "Settings for the smtp client";
      };
    };
  };

  ## implementation
  config = mkIf config.services.pickup.enable {
    users.extraGroups = singleton {
      name = "pickup";
      gid = config.ids.gids.pickup;
    };

    users.extraUsers = singleton {
      name = "pickup";
      uid = config.ids.uids.pickup;
      extraGroups = [ "pickup" ];
      description = "Pickup daemon user.";
    };

    systemd.services.pickup = {
      description = "Pickup server";
      after = [ "networking.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.gawk ];
      preStart = ''
        mkdir -p ${cfg.baseDir}
        chown ${user}:pickup ${cfg.baseDir}
      '';

      script =
        if user == "root" then "${pkgs.pickup}/bin/pickup-admin ${configFile}"
        else "${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh ${user} -c \"${pkgs.pickup}/bin/pickup-admin ${configFile}\"";
    };
  };
}

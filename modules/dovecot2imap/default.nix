{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.dovecot2imap;
  dovecotConf =
    ''
      base_dir = ${cfg.baseDir}

      protocols = ${optionalString cfg.enableImap "imap"} ${optionalString cfg.enablePop3 "pop3"}
    ''
    + (if cfg.sslServerCert!="" then
    ''
      ssl = yes
      ssl_cert = <${cfg.sslServerCert}
      ssl_key = <${cfg.sslServerKey}
      ssl_ca = <${cfg.sslCACert}
      disable_plaintext_auth = yes
    '' else ''
      ssl = no
      disable_plaintext_auth = no
    '')

    + ''
      default_internal_user = ${cfg.user}

      mail_location = ${cfg.mailLocation}

      maildir_copy_with_hardlinks = yes

      auth_mechanisms = plain login
      service auth {
        user = root
      }
      userdb {
        ${cfg.userDb}
      }
      passdb {
        ${cfg.passDb}
      }

      first_valid_uid = 399

    '' + cfg.extraConfig;

  confFile = pkgs.writeText "dovecot2.conf" dovecotConf;
in
{

  ###### interface

  options = {

    services.dovecot2imap = {

      baseDir = mkOption {
        default = "/var/run/dovecot2";
        description = "Dovcot working directory.";
      };

      enable = mkOption {
        default = false;
        description = "Whether to enable the Dovecot 2.x POP3/IMAP server.";
      };

      enablePop3 = mkOption {
        default = true;
        description = "Start the POP3 listener (when Dovecot is enabled).";
      };

      enableImap = mkOption {
        default = true;
        description = "Start the IMAP listener (when Dovecot is enabled).";
      };

      user = mkOption {
        default = "dovecot2";
        description = "Dovecot user name.";
      };

      group = mkOption {
        default = "dovecot2";
        description = "Dovecot group name.";
      };

      extraConfig = mkOption {
        default = "";
        example = "mail_debug = yes";
        description = "Additional entries to put verbatim into Dovecot's config file.";
      };

      mailLocation = mkOption {
        default = "maildir:/var/spool/mail/%u"; /* Same as inbox, as postfix */
        description = ''
          Location that dovecot will use for mail folders. Dovecot mail_location option.
        '';
      };

      sslServerCert = mkOption {
        default = "";
        description = "Server certificate";
      };

      sslCACert = mkOption {
        default = "";
        description = "CA certificate used by the server certificate.";
      };

      sslServerKey = mkOption {
        default = "";
        description = "Server key.";
      };

      userDb = mkOption {
        default = "driver = passwd";
        description = "Lines added to the <literal>userDb</literal> block.";
      };

      passDb = mkOption {
        default = "driver = pam";
        description = "Lines added to the <literal>passDb</literal> block.";
      };

    };

  };


  ###### implementation

  config = mkIf config.services.dovecot2imap.enable {

    users.extraUsers = [
      { name = cfg.user;
        uid = config.ids.uids.dovecot2;
        description = "Dovecot user";
        group = cfg.group;
      }
      { name = "dovenull";
        uid = config.ids.uids.dovenull2;
        description = "Dovecot user for untrusted logins";
        group = cfg.group;
      }
    ];

    users.extraGroups = singleton
      { name = cfg.group;
        gid = config.ids.gids.dovecot2;
      };

    jobs.dovecot2imap = {
      description = "Dovecot IMAP/POP3 server";
      startOn = "started networking";
      preStart =
        ''
          ${pkgs.coreutils}/bin/mkdir -p ${cfg.baseDir}/login
          ${pkgs.coreutils}/bin/chown -R ${cfg.user}:${cfg.group} ${cfg.baseDir}
        '';
      exec = "${pkgs.dovecot}/sbin/dovecot -F -c ${confFile}";
    };

    environment.systemPackages = [ pkgs.dovecot ];

    assertions = [{ assertion = cfg.enablePop3 || cfg.enableImap;
                    message = "dovecot needs at least one of the IMAP or POP3 listeners enabled";}];

  };

}

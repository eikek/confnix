{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.dovecot2imap;

  dovecotConf =
    ''
      base_dir = /var/run/dovecot2/

      protocols = ${optionalString cfg.enableImap "imap"} ${optionalString cfg.enablePop3 "pop3"}
    ''
    + (if cfg.sslServerCert!="" then
    ''
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
        driver = static
        args = uid=exim gid=exim home=/var/users/%u
      }
      passdb {
        driver = checkpassword
        args = ${checkpasswordScript}
      }

      first_valid_uid = 399

    '' + cfg.extraConfig;

  confFile = pkgs.writeText "dovecot2.conf" dovecotConf;
  checkpassword = ''
  #!/bin/sh

  REPLY="$1"
  INPUT_FD=3
  ERR_FAIL=1
  ERR_NOUSER=3
  ERR_TEMP=111

  read -d ''$'\x0' -r -u $INPUT_FD USER
  read -d ''$'\x0' -r -u $INPUT_FD PASS

  echo "Not an error ;-) Dovecot checkpassword: $USER : $PASS > $REPLY" >> /dev/stderr

  [ "$AUTHORIZED" != 1 ] || export AUHORIZED=2

  if [ "$CREDENTIALS_LOOKUP" = 1 ]; then
    exit $ERR_FAIL
  else
    if ${pkgs.shelter}/bin/shelter_auth localhost:7910 $USER $PASS mail; then
        exec $REPLY
    else
        exit $ERR_FAIL
    fi
  fi
  '';

  checkpasswordScript = pkgs.writeScript "checkpassword-dovecot.sh" checkpassword;

in

{

  ###### interface

  options = {

    services.dovecot2imap = {

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
        default = "maildir:/var/exim/mail/%u";
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
          ${pkgs.coreutils}/bin/mkdir -p /var/run/dovecot2 /var/run/dovecot2/login
          ${pkgs.coreutils}/bin/chown -R ${cfg.user}:${cfg.group} /var/run/dovecot2
        '';
      exec = "${pkgs.dovecot}/sbin/dovecot -F -c ${confFile}";
    };

    environment.systemPackages = [ pkgs.dovecot ];

    assertions = [{ assertion = cfg.enablePop3 || cfg.enableImap;
                    message = "dovecot needs at least one of the IMAP or POP3 listeners enabled";}];

  };

}

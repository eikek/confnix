{ config, pkgs, lib, ... }:
#
# fetchmail run in daemon mode. passwords are retrieved from .netrc
# file.
#
with config;
with lib;
let
  cfg = config.services.fetchmail;
in
{
  options = {
    services.fetchmail = {
      enable = mkOption {
        default = false;
        description = "Whether to enable the fetchmail daemon.";
      };
      pollIntervall = mkOption {
        default = 2700;
        description = "The intervall in seconds to poll for mail.";
      };
      fetchmailHome = mkOption {
        default = "/var/data/fetchmail";
        description = "Home directory for fetchmail.";
      };
      postmaster = mkOption {
        default = "postmaster";
        description = "The last-resort user that gets mails.";
      };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.fetchmail ];

    users.extraGroups = singleton {
      name = "fetchmail";
      gid = config.ids.gids.fetchmail;
    };

    users.extraUsers = singleton {
      name = "fetchmail";
      uid = config.ids.uids.fetchmail;
      createHome = true;
      home = cfg.fetchmailHome;
      extraGroups = ["fetchmail"];
      description = "Fetchmail daemon user.";
    };

    systemd.services.fetchmail = {
      description = "Fetchmail daemon.";
      wantedBy = [ "multi-user.target" ];
      after = [ "networking.target" ];

      preStart = ''
      mkdir -p ${cfg.fetchmailHome}
      if ! [ -r ${cfg.fetchmailHome}/.fetchmailrc ]; then
          touch ${cfg.fetchmailHome}/.fetchmailrc
      fi
      if ! [ -r ${cfg.fetchmailHome}/.netrc ]; then
          touch ${cfg.fetchmailHome}/.netrc
      fi
      chown fetchmail:fetchmail ${cfg.fetchmailHome}/{.fetchmailrc,.netrc}
      chmod 600 ${cfg.fetchmailHome}/{.fetchmailrc,.netrc}
      '';

      serviceConfig = {
        Type = "forking";
      };

      script=''
      ${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh fetchmail -c "${pkgs.fetchmail}/bin/fetchmail -d ${builtins.toString cfg.pollIntervall} --syslog --postmaster ${cfg.postmaster}"
      '';
    };
  };
}

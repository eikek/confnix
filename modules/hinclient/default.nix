{config, lib, pkgs, ...}:

with lib;
let
  cfg = config.services.hinclient;
  str = e: if (builtins.typeOf e) == "bool" then (if e then "true" else "false") else (builtins.toString e);
in {

  ## interface
  options = {
    services.hinclient = {
      enable = mkOption {
        default = false;
        description = "Whether to enable HIN Client.";
      };

      user = mkOption {
        default = "";
        description = "The system user to run HIN Client.";
      }

      identities = mkOption {
        default = "";
        description = "The identities parameter";
      };

      passphrase = mkOption {
        default = "";
        description = "The file name containing the passphrase";
      };

      keystore = mkOption {
        default = "";
        description = "The file denoting the hin keyster (hin identity)";
      };

      baseDir = mkOption {
        default = "/var/run/hinclient";
        description = "The base directory for running HIN Client.";
      };
    };
  };

  ## implementation
  config = mkIf cfg.enable {
    systemd.services.hinclient = {
      description = "HIN Client";
      after = [ "networking.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        export JAVA_HOME=${pkgs.jre}
      '';

      script = ''
        ${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh ${cfg.user} -c "cd ${cfg.baseDir} && ${pkgs.hinclient}/hinclient headless identities=${cfg.identities} keystore=${cfg.keystore} passphrase=${cfg.passphrase} "
      '';
    };
  };
}

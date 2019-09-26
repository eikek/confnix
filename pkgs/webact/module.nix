{config, lib, pkgs, ...}:

with lib;
let
  cfg = config.services.webact;
  user = if cfg.runAs == null then "webact" else cfg.runAs;
  paths = with builtins;
    (map (p: "${p}/bin") cfg.extraPackages) ++ (cfg.extraPaths);

  configFile = pkgs.writeText "webact.conf" ''
    webact {
      app-name = "${cfg.appName}"

      script-dir = "${cfg.baseDir}/scripts"
      tmp-dir = "${cfg.baseDir}/temp"

      inherit-path = ${if cfg.inheritPath then "true" else "false"}

      extra-path = ${builtins.toJSON paths}

      env = ${builtins.toJSON cfg.extraEnv}

      bind {
        host = "${cfg.bindHost}"
        port = ${toString cfg.bindPort}
      }

      smtp {
        host = "${cfg.smtpHost}"
        port = ${toString cfg.smtpPort}
        user = "${cfg.smtpUser}"
        password = "${cfg.smtpPassword}"
        start-tls = ${if cfg.smtpStartTls then "true" else "false"}
        use-ssl = ${if cfg.smtpUseSsl then "true" else "false"}
        sender = "${cfg.smtpSender}"
      }
    }
  '';
in {

  ## interface
  options = {
    services.webact = {
      enable = mkOption {
        default = false;
        description = "Whether to enable webact.";
      };

      runAs = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          The user that runs the webact server process. If this is
          null, a new user webact is created. If specified, the user
          must exist.
        '';
      };
      userService = mkOption {
        type = types.bool;
        default = false;
        description = "If true, then webact is a systemd-user service and the runAs option is ignored.";
      };

      baseDir = mkOption {
        type = types.path;
        default = "/var/data/webact";
        description = "The folder where webact stores the scripts and temporary files.";
      };

      appName = mkOption {
        type = types.str;
        default = "Webact";
        description = "The name used in the web ui and in notification mails.";
      };

      inheritPath = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to inherit the PATH variable from server process into scripts";
      };

      extraPackages = mkOption {
        type = types.listOf types.package;
        default = [];
        description = ''
          A list of packages where their bin/ directory are added to
          the PATH variable available in scripts.

          This and `extraPaths` are concatenated.
        '';
      };

      extraPaths = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
           A list of paths that is added to the PATH variable avaiable
          to the scripts.
        '';
      };

      extraEnv = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = ''
          Extra environment variables added to every script run.
        '';
      };

      bindHost = mkOption {
        type = types.str;
        default = "localhost";
        description = "The address to bind the webserver";
      };
      bindPort = mkOption {
        type = types.int;
        default = 8011;
        description = "The port to bind the web server";
      };

      smtpHost = mkOption {
        type = types.str;
        default = "";
        description = "The smtp host to use for sending notification mails. If empty, the MX host of each recipient is used.";
      };
      smtpPort = mkOption {
        type = types.int;
        default = 0;
        description = "The smtp port to use for sending notification mails.";
      };
      smtpUser = mkOption {
        type = types.str;
        default = "";
        description = "The username to use for authentication on smtp server";
      };
      smtpPassword = mkOption {
        type = types.str;
        default = "";
        description = "The password to use for authentication on smtp server";
      };
      smtpStartTls = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to connect via SartTLS";
      };
      smtpUseSsl = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to connect via SSL";
      };
      smtpSender = mkOption {
        type = types.str;
        default = "noreply@localhost";
        description = "The sender email address to use.";
      };

    };
  };

  ## implementation
  config = mkIf config.services.webact.enable {
    users.extraGroups = singleton {
      name = "webact";
      gid = config.ids.gids.webact;
    };

    users.extraUsers = singleton {
      name = "webact";
      uid = config.ids.uids.webact;
      extraGroups = [ "webact" ];
      description = "Webact daemon user.";
    };

    networking.firewall.allowedTCPPorts = [ cfg.bindPort ];

    systemd.user.services.webact = mkIf config.services.webact.userService {
      description = "Webact User Service";
      wantedBy = [ "default.target" ];
      restartIfChanged = true;
      serviceConfig = {
        RestartSec = 3;
        Restart = "always";
      };
      path = [ pkgs.gawk ];
      preStart = ''
        mkdir -p ${cfg.baseDir}
      '';

      script = "${pkgs.webact}/bin/webact -J-Xmx100m ${configFile}";
    };

    systemd.services.webact = mkIf (!config.services.webact.userService) {
      description = "Webact Service";
      after = [ "networking.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.gawk ];
      preStart = ''
        mkdir -p ${cfg.baseDir}
        chown ${user}:webact ${cfg.baseDir}
      '';

      script =
        if user == "root" then "${pkgs.webact}/bin/webact ${configFile}"
        else "${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh ${user} -c \"${pkgs.webact}/bin/webact -J-Xmx100m ${configFile}\"";
    };
  };
}

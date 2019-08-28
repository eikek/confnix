{config, lib, pkgs, ...}:

with lib;
let
  cfg = config.services.gossa;
in {

  ## interface
  options = {
    services.gossa = {
      enable = mkOption {
        default = false;
        description = "Whether to enable gossa.";
      };

      port = mkOption {
        default = 8001;
        description = "The port used to bind the server.";
      };

      host = mkOption {
        default = "localhost";
        description = "The host to bind the server.";
      };

      skipHiddenFiles = mkOption {
        default = true;
        description = "Whether to skip hidden files";
      };

      baseDir = mkOption {
        default = "/var/data/gossa";
        description = "Location that gossa serves (recursively).";
      };

      user = mkOption {
        default = null;
        description = "The user running the server process. If null, a new user `gossa` is created for this.";
      };
    };
  };

  ## implementation
  config = mkIf config.services.gossa.enable {
    users.extraGroups = singleton {
      name = "gossa";
      gid = config.ids.gids.gossa;
    };

    users.extraUsers = mkIf (config.services.gossa.user == null) (singleton {
      name = "gossa";
      uid = config.ids.uids.gossa;
      extraGroups = [ "gossa" ];
      description = "Gossa daemon user.";
    });

    networking.firewall.allowedTCPPorts = [ cfg.port ];

    systemd.services.gossa = let username = if config.services.gossa.user == null then "gossa" else config.services.gossa.user; in {
      description = "Gossa server";
      after = [ "networking.target" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        mkdir -p ${cfg.baseDir}
        chown ${username} ${cfg.baseDir}
      '';

      script = "${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh ${username} -c \"${pkgs.gossa}/bin/gossa -h ${cfg.host} -p ${toString cfg.port} ${if cfg.skipHiddenFiles then "-k" else ""} ${cfg.baseDir}\"";
    };
  };
}

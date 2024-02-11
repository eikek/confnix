{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.mpc4s;
  user = if cfg.runAs == null then "mpc4s" else cfg.runAs;
  paths = with builtins;
    (map (p: "${p}/bin") cfg.extraPackages) ++ (cfg.extraPaths);

  configFile = pkgs.writeText "mpc4s.conf" ''
    mpc4s {
      http {
        app-name = "${cfg.appName}"
        baseurl = "${cfg.baseUrl}"
        bind {
          host = "${cfg.bindHost}"
          port = ${toString cfg.bindPort}
        }

        music-directory = "${cfg.musicDirectory}"

        mpd.configs ${builtins.toJSON cfg.mpdConfigs}

        cover-thumbnails {
          directory = ${cfg.coverThumbDir}
        }
      }
    }
  '';
in
{

  ## interface
  options = {
    services.mpc4s = {
      enable = mkOption {
        default = false;
        description = "Whether to enable mpc4s.";
      };

      userService = mkOption {
        type = types.bool;
        default = false;
        description = "If true, then mpc4s is a systemd-user service.";
      };

      baseUrl = mkOption {
        type = types.str;
        default = "http://localhost:9600";
        description = "The base url used to create urls";
      };

      musicDirectory = mkOption {
        type = types.path;
        default = null;
        description = "The music directory that is also available to mpd";
      };

      mpdConfigs = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            host = mkOption {
              type = types.str;
              example = "127.0.0.1";
              description = "The host or ip address to reach MPD";
            };
            port = mkOption {
              type = types.int;
              example = 6600;
              description = "The port MPD listens to";
            };
            max-connections = mkOption {
              type = types.int;
              default = 5;
              description = "Maximum number of simultaneous connections mpc4s creates to MPD.";
            };
            timeout = mkOption {
              type = types.str;
              default = "5 seconds";
              description = "Timeout for MPD commands.";
            };
            title = mkOption {
              type = types.str;
              example = "Living Room";
              description = "A human readable title for this MPD";
            };
          };
        });
      };

      coverThumbDir = mkOption {
        type = types.path;
        default = "/var/data/mpc4s/coverThumbs";
        description = "The folder where mpc4s stores thumbnails to cover images.";
      };

      appName = mkOption {
        type = types.str;
        default = "Mpc4s";
        description = "The name used in the web ui.";
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
    };
  };

  ## implementation
  config = mkIf config.services.mpc4s.enable {
    users.groups.mpc4s = {
      gid = config.ids.gids.mpc4s;
    };

    users.users.mpc4s = {
      uid = config.ids.uids.mpc4s;
      extraGroups = [ "mpc4s" ];
      description = "Mpc4s daemon user.";
    };

    networking.firewall.allowedTCPPorts = [ cfg.bindPort ];

    systemd.user.services.mpc4s = mkIf config.services.mpc4s.userService {
      description = "Mpc4s User Service";
      after = [ "networking.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.gawk ];
      preStart = ''
        mkdir -p ${cfg.coverThumbDir}
      '';

      script = "${pkgs.mpc4s}/bin/mpc4s ${configFile}";
    };

    systemd.services.mpc4s = mkIf (!config.services.mpc4s.userService) {
      description = "Mpc4s Service";
      after = [ "networking.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.gawk ];
      preStart = ''
        mkdir -p ${cfg.coverThumbDir}
        chown mpc4s:mpc4s ${cfg.coverThumbDir}
      '';

      script = "${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh mpc4s -c \"${pkgs.mpc4s}/bin/mpc4s ${configFile}\"";
    };
  };
}

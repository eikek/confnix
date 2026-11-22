{ config, pkgs, ... }:
let
  sshkeys = import ../../secrets/ssh-keys.nix;
in

{
  users.users.ventoux = {
    name = "ventoux";
    isNormalUser = true;
    uid = 1002;
    createHome = true;
    home = "/home/ventoux";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys =
      if builtins.hasAttr "eike" sshkeys then [ sshkeys.eike ] else [ ];
  };

  networking.firewall = {
    allowedTCPPorts = [ 8888 8181 ];
  };

  age.secrets."ventouxdemo-serversecret" = {
    file = ../../secrets/ventouxdemo-serversecret.age;
    owner = "ventouxdemo";
  };
  age.secrets."ventouxdemo-pg" = {
    file = ../../secrets/ventouxdemo-pg.age;
    owner = "ventouxdemo";
  };

  services.ventouxdemo =
    let
      ventouxpkg = pkgs.ventoux.overrideAttrs (final: prev: {
        src = pkgs.fetchurl {
          url = "http://eknet.org/pkgs/ventoux-0.3.0-36-165c438.zip";
          sha256 = "sha256-fAHPrMNbYDs4VB4wDgsS7+g/CyXY3urVLCB7eJ75+74=";
        };
      });
    in
    {
    enable = true;
    package = ventouxpkg;
    user = "ventouxdemo";
    settings = {
      VENTOUX_BIND_HOST = "0.0.0.0";
      VENTOUX_BIND_PORT = "8181";
      VENTOUX_TASKS_RUNNER_ID = "main-runner";

      VENTOUX_POSTGRES_DATABASE = "ventouxdemo";
      VENTOUX_POSTGRES_USER = "ventouxdemo";
      VENTOUX_POSTGRES_PASSWORD_FILE = config.age.secrets."ventouxdemo-pg".path;
      VENTOUX_SERVER_SECRET_FILE = config.age.secrets."ventouxdemo-serversecret".path;
      VENTOUX_BASE_URI = "https://demo.ventoux.fit";
      VENTOUX_WEBAPP_NAME = "Ventoux Demo";
      VENTOUX_WEBAPP_MAX_FILES_UPLOAD = "5";
      VENTOUX_LOGGING_FORMAT = "short";
      VENTOUX_MAX_UPLOAD_SIZE = "5M";

      VENTOUX_LOGGING_MIN_LEVEL = "Error";
      VENTOUX_LOGGING_LEVELS_NAMES = "ventoux";
      VENTOUX_LOGGING_LEVELS_VENTOUX = "Debug";
      VENTOUX_SIGNUP_MODE = "open";
      VENTOUX_FEDERATION_ENABLED = "true";
      VENTOUX_WEBAPP_GRAVATAR_DEFAULT_IMAGE = "robohash";
    };
  };

  systemd.services.reset-ventouxdemo-db = {
    description = "Reset demo PostgreSQL database";
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };

    path = [ pkgs.postgresql_18 pkgs.systemd ];

    script = ''
      set -eu

      systemctl stop ventouxdemo.service
      trap 'systemctl start ventouxdemo.service' EXIT

      ${pkgs.postgresql_18}/bin/dropdb --if-exists --force ventouxdemo
      ${pkgs.postgresql_18}/bin/createdb --owner=ventouxdemo ventouxdemo
    '';
  };

  systemd.timers.reset-ventouxdemo-db = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Mon *-*-* 02:00:00";
      Persistent = true;
      Unit = "reset-ventouxdemo-db.service";
    };
  };
}

{ config, pkgs, nixpkgs-unstable, ... }:
let
  unstable = import nixpkgs-unstable {
    system = pkgs.stdenv.system;
    config = { allowUnfree = true; };
  };


  # photoprism cli. https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/services/web-apps/photoprism.nix
  cfg = config.services.photoprism;
  lib = pkgs.lib;
  env = {
    PHOTOPRISM_ORIGINALS_PATH = cfg.originalsPath;
    PHOTOPRISM_STORAGE_PATH = cfg.storagePath;
    PHOTOPRISM_IMPORT_PATH = cfg.importPath;
    PHOTOPRISM_HTTP_HOST = cfg.address;
    PHOTOPRISM_HTTP_PORT = toString cfg.port;
  }
  // (lib.mapAttrs (_: toString) cfg.settings);

  manage = pkgs.writeShellScriptBin "pp-manage" ''
    set -o allexport # Export the following env vars
    ${lib.toShellVars env}
    eval "$(${config.systemd.package}/bin/systemctl show -pUID,MainPID photoprism.service | ${pkgs.gnused}/bin/sed "s/UID/ServiceUID/")"
    exec ${pkgs.util-linux}/bin/nsenter \
      -t $MainPID -m -S $ServiceUID -G $ServiceUID --wdns=${cfg.storagePath} \
      ${cfg.package}/bin/photoprism "$@"
  '';
in
{

  services.mysql = {
    enable = true;
    dataDir = "/mnt/data1/mariadb";
    package = pkgs.mariadb;
    ensureDatabases = [ "photoprism" ];
    ensureUsers = [{
      name = "photoprism";
      ensurePermissions = {
        "photoprism.*" = "ALL PRIVILEGES";
      };
    }];
  };

  users.users.photoprism = {
    isNormalUser = false;
    isSystemUser = true;
    group = "photoprism";
    useDefaultShell = true;
  };
  users.groups = { photoprism = { }; };

  services.photoprism = {
    enable = true;
    package = unstable.photoprism;
    address = "0.0.0.0";
    storagePath = "/mnt/data1/photoprism/storage";
    originalsPath = "/mnt/nas/data/photo/kamera-sdcard";
    # doesn't work, pass it to standard environment
    #passwordFile = "/mnt/data1/photoprism/password";
    settings = {
      PHOTOPRISM_DEFAULT_LOCALE = "de";
      PHOTOPRISM_DEFAULT_TIMEZONE = "Europe/Berlin";
      PHOTOPRISM_USERS_PATH = "/mnt/disk1/photoprism/users";
      PHOTOPRISM_READONLY = "true";
      PHOTOPRISM_DISABLE_RESTART = "true";
      PHOTOPRISM_DATABASE_DRIVER = "mysql";
      PHOTOPRISM_DATABASE_NAME = "photoprism";
      PHOTOPRISM_DATABASE_SERVER = "/run/mysqld/mysqld.sock";
      PHOTOPRISM_DATABASE_USER = "photoprism";
      PHOTOPRISM_LOG_LEVEL = "info";
      PHOTOPRISM_ADMIN_PASSWORD_FILE = "/mnt/data1/photoprism/password";
    };
  };


  fileSystems = {
    "/mnt/nas/data" = {
      device = "//files.home/data";
      fsType = "cifs";
      noCheck = true;
      options = [
        "username=eike"
        "password=eike"
        "vers=2.0"
        "uid=0"
        "gid=1"
        "ro"
        "filemode=0644"
        #"fsc" # local disk caching
      ];
    };
  };

  environment.systemPackages = [ pkgs.photoprism manage ];

  networking.firewall.allowedTCPPorts = [ 2342 ];


  system.activationScripts = {
    photoprism-directory = ''
      chown -R photoprism /mnt/data1/photoprism 
    '';
  };
}

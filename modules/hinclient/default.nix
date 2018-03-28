# unfortunately, HIN Client doesn't work with recent java8 versions
# (but requires java8). So add an older nixpkgs version to nix_path
# requires to run nix-rebuild with for example
#   -I oldpkgs=https://github.com/NixOS/nixpkgs/archive/17.03.tar.gz
#
{config, lib, pkgs, ...}:

with lib;
let
  cfg = config.services.hinclient;
  str = e: if (builtins.typeOf e) == "bool" then (if e then "true" else "false") else (builtins.toString e);
  oldpkgs = import <nixos1703> {};
in {

  ## interface
  options = {
    services.hinclient = {
      enable = mkOption {
        default = false;
        description = "Whether to enable HIN Client.";
      };

      user = mkOption {
        default = "hinclient";
        description = "The system user to run HIN Client.";
      };

      identities = mkOption {
        default = "";
        description = "The identities parameter";
      };

      passphrase = mkOption {
        default = "";
        description = "The file containing the passphrase";
      };

      keystore = mkOption {
        default = "";
        description = "The file denoting the hin keystore (hin identity)";
      };

      baseDir = mkOption {
        default = "/var/run/hinclient";
        description = "The base directory for running HIN Client.";
      };

      hinClientPackage = mkOption {
        default = pkgs.hinclient;
        description = "The hin client package";
      };

      language = mkOption {
        default = "de";
        description = "The language: de, en or fr";
      };

      httpProxyPort = mkOption {
        default = 5016;
        description = "The port used for local http proxy.";
      };

      smtpProxyPort = mkOption {
        default = 5018;
        description = "The port used for local smtp proxy.";
      };

      clientapiPort = mkOption {
        default = 5017;
        description = "Port for client api connections.";
      };

      pop3ProxyPort = mkOption {
        default = 5019;
        description = "Port for local pop3 proxy.";
      };

      imapProxyPort = mkOption {
        default = 5020;
        description = "Port for local imap proxy";
      };
    };
  };

  ## implementation
  config = mkIf cfg.enable {
    users.extraUsers = singleton {
      name = cfg.user;
      home = cfg.baseDir;
    };

    systemd.services.hinclient = {
      description = "HIN Client";
      after = [ "networking.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        JAVA_HOME = "${oldpkgs.jre8}";
        HOME = "${cfg.baseDir}";
        INSTALL4J_ADD_VM_PARAMS = "-Djava.io.tmpdir=${cfg.baseDir}/tmp";
      };
      preStart = ''
        mkdir -p ${cfg.baseDir}/tmp
        for name in .install4j help lib hinclient cert-prod.jks; do
          ln -nfs ${cfg.hinClientPackage}/$name ${cfg.baseDir}/
        done
        cp ${cfg.hinClientPackage}/hinclient.*.properties ${cfg.baseDir}/

        chown -R ${cfg.user} ${cfg.baseDir}
      '';
      script = ''
        ${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh ${cfg.user} -c "cd ${cfg.baseDir} && ./hinclient headless \
          identities=${cfg.identities} \
          keystore=${cfg.keystore} \
          passphrase=${cfg.passphrase} \
          hinclient.httpproxy.port=${builtins.toString cfg.httpProxyPort} \
          hinclient.clientapi.port=${builtins.toString cfg.clientapiPort} \
          hinclient.smtpproxy.port=${builtins.toString cfg.smtpProxyPort} \
          hinclient.pop3proxy.port=${builtins.toString cfg.pop3ProxyPort} \
          hinclient.imapproxy.port=${builtins.toString cfg.imapProxyPort} \
          language=${cfg.language}
         "
      '';
    };
  };
}

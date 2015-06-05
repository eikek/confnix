{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ejabberd15;
  ejabberdConf = pkgs.writeText "ejabberd.yml" ''
    loglevel: ${builtins.toString cfg.loglevel}
    log_rotate_size: 0
    log_rotate_date: "$M1D0"
    log_rotate_count: 12
    log_rate_limit: 100

    hosts:
      - ${concatMapStringsSep "\n  - " (s: "\""+ s +"\"") cfg.hosts}

    listen:
      -
        port: 5222
        module: ejabberd_c2s
        ${if (cfg.certfile != null) then ''certfile: "${cfg.certfile}"'' else "# no certificate file"}
        ${if (cfg.certfile != null) then "starttls_required: true" else "# no certificate file"}
        max_stanza_size: 65536
        shaper: c2s_shaper
        access: c2s
      -
        port: 5269
        module: ejabberd_s2s_in

      -
        port: 5280
        module: ejabberd_http
        request_handlers:
          "/websocket": ejabberd_http_ws
        ##  "/pub/archive": mod_http_fileserver
        web_admin: true
        http_bind: true
        ## register: true
        captcha: true

    auth_method: ${if (cfg.externalAuthProgram != null) then "external" else "internal"}
    ${if (cfg.externalAuthProgram != null) then ''extauth_program: "${cfg.externalAuthProgram}"'' else "# not external auth method"}

    shaper:
      normal: 1000
      fast: 50000

    max_fsm_queue: 1000
    acl:
      admin:
        user:
          - ${let jid = splitString "@" cfg.adminUser; in ''"${builtins.elemAt jid 0}" : "${builtins.elemAt jid 1}"''}
      local:
        user_regexp: ""
      loopback:
        ip:
          - "127.0.0.0/8"

    access:
      max_user_sessions:
        all: 10
      max_user_offline_messages:
        admin: 5000
        all: 100
      local:
        local: allow
      c2s:
        blocked: deny
        all: allow
      c2s_shaper:
        admin: none
        all: normal
      s2s_shaper:
        all: fast
      announce:
        admin: allow
      configure:
        admin: allow
      muc_admin:
        admin: allow
      muc_create:
        local: allow
      muc:
        all: allow
      pubsub_createnode:
        local: allow
      register:
        all: allow
      trusted_network:
        loopback: allow

    language: en

    modules:
      mod_adhoc: {}
      mod_announce: # recommends mod_adhoc
        access: announce
      mod_blocking: {} # requires mod_privacy
      mod_caps: {}
      mod_carboncopy: {}
      mod_client_state:
        drop_chat_states: true
        queue_presence: false
      mod_configure: {} # requires mod_adhoc
      mod_disco: {}
      ## mod_echo: {}
      mod_irc: {}
      mod_http_bind: {}
      mod_last: {}
      mod_muc:
        access: muc
        access_create: muc_create
        access_persistent: muc_create
        access_admin: muc_admin
      mod_offline:
        access_max_user_messages: max_user_offline_messages
      mod_ping: {}
      mod_privacy: {}
      mod_private: {}
      mod_pubsub:
        access_createnode: pubsub_createnode
        ## reduces resource comsumption, but XEP incompliant
        ignore_pep_from_offline: true
        ## XEP compliant, but increases resource comsumption
        ## ignore_pep_from_offline: false
        last_item_cache: false
        plugins:
          - "flat"
          - "hometree"
          - "pep" # pep requires mod_caps
      mod_roster: {}
      mod_shared_roster: {}
      mod_stats: {}
      mod_time: {}
      mod_vcard: {}
      mod_version: {}

    allow_contrib_modules: true
  '';

  ejctl = pkgs.stdenv.mkDerivation {
    name = "ejctl";
    buildCommand = ''
      mkdir -p $out/bin
      cat >> $out/bin/ejctl <<-"EOF"
      #!${pkgs.bash}/bin/bash
      export HOME=${cfg.spoolDir}
      export ETC_DIR=${cfg.spoolDir}/etc
      ${pkgs.ejabberd15}/bin/ejabberdctl \
          --config-dir ${cfg.spoolDir}/etc \
          --logs ${cfg.spoolDir}/logs \
          --spool ${cfg.spoolDir}/spool \
          --ctl-config ${cfg.spoolDir}/etc/ejabberdctl.cfg $@
      EOF
      chmod a+x $out/bin/ejctl
    '';
  };
in {

### interface

  options = {
    services.ejabberd15 = {
      enable = mkOption {
        default = false;
        description = "Whether to enable the ejabberd server.";
      };

      spoolDir = mkOption {
        default = "/var/run/ejabberd15";
        description = "State dir for ejabberd";
      };

      loglevel = mkOption {
        default = 4;
        description = "Log level, 1 to 5";
      };

      hosts = mkOption {
        default = ["localhost"];
        description = "List of hostnames/domains to serve.";
      };

      certfile = mkOption {
        default = null;
        description = "Path to a certificate file.";
      };

      externalAuthProgram = mkOption {
        default = null;
        description = "Path to a authentication script that is used instead of internal auth.";
      };

      adminUser = mkOption {
        default = "admin@localhost";
        description = "admin user jid";
      };
    };
  };


### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.ejabberd15 ejctl ];

    systemd.services.ejabberd15 = {
      description = "The ejabberd xmpp server.";
      wantedBy = [ "multi-user.target" ];
      after = [ "networking.target" ];
      serviceConfig = {
        Type = "forking";
        PIDFile = "${cfg.spoolDir}/ejabberd.pid";
      };
      preStart = ''
        mkdir -p ${cfg.spoolDir}/{spool,logs,etc}
        ln -snf ${ejabberdConf} ${cfg.spoolDir}/etc/ejabberd.yml
        cp ${pkgs.ejabberd15}/etc/ejabberd/inetrc ${cfg.spoolDir}/etc
        cp ${pkgs.ejabberd15}/etc/ejabberd/ejabberdctl.cfg ${cfg.spoolDir}/etc
        sed -i 's|\#EJABBERD_CONFIG_PATH=/etc/ejabberd/ejabberd.yml|EJABBERD_CONFIG_PATH=${ejabberdConf}|g' ${cfg.spoolDir}/etc/ejabberdctl.cfg
        sed -i 's|\#EJABBERD_PID_PATH=/var/run/ejabberd/ejabberd.pid|EJABBERD_PID_PATH=${cfg.spoolDir}/ejabberd.pid|g' ${cfg.spoolDir}/etc/ejabberdctl.cfg
        echo "EJABBERD_BYPASS_WARNINGS=true" >> ${cfg.spoolDir}/etc/ejabberdctl.cfg
      '';

      script = ''
        ${ejctl}/bin/ejctl start
      '';

      preStop = ''
        ${ejctl}/bin/ejctl stop
      '';
    };
  };
}

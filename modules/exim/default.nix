{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.exim;
  user = "exim";
  group = "exim";
  version = "4.84";
  eximConfig = ''
    primary_hostname = ${cfg.primaryHostname}
    domainlist local_domains = ${concatStringsSep ":" cfg.localDomains}
    domainlist relay_to_domains =
    hostlist   relay_from_hosts = ${cfg.relayFromHosts}

    LOCAL_USERS = ${cfg.localUsers}
    MAIL_ALIASES = ${cfg.mailAliases}

    ${if (cfg.perlScript == null) then "" else ''
      perl_startup = do '${cfg.stateDir}/etc/exim.pl'
    ''}

    acl_smtp_rcpt = acl_check_rcpt
    acl_smtp_data = acl_check_data

    tls_advertise_hosts = *
    tls_certificate = ${cfg.tlsCertificate}
    tls_privatekey = ${cfg.tlsPrivatekey}

    daemon_smtp_ports = ${cfg.smtpPorts}

    host_lookup = *
    ignore_bounce_errors_after = 2d
    timeout_frozen_after = 7d

    spool_directory = ${cfg.stateDir}/spool
    split_spool_directory = true
    check_rfc2047_length = false

    message_size_limit = ${cfg.messageSizeLimit}

    begin acl
    acl_check_rcpt:
      accept hosts = :
             control = dkim_disable_verify

      deny   message       = Restricted characters in address
             domains       = +local_domains
             local_parts   = ^[.] : ^.*[@%!/|]
      deny   message       = Restricted characters in address
             domains       = !+local_domains
             local_parts   = ^[./|] : ^.*[@%!] : ^.*/\\.\\./

      accept local_parts   = postmaster
             domains       = +local_domains

      deny   message       = Unknown user
             domains       = +local_domains
             local_parts   = ! LOCAL_USERS : MAIL_ALIASES

      require verify        = sender

      accept  hosts         = +relay_from_hosts
              control       = submission
              control       = dkim_disable_verify

      accept  authenticated = *
              control       = submission
              control       = dkim_disable_verify

      require message = relay not permitted
              domains = +local_domains : +relay_to_domains

      require verify = recipient
      accept

    acl_check_data:
      accept

    begin routers
    dnslookup:
      driver = dnslookup
      domains = ! +local_domains
      transport = remote_smtp
      #ignore_target_hosts = 0.0.0.0 : 127.0.0.0/8
      # if ipv6-enabled then instead use:
      ignore_target_hosts = <; 0.0.0.0 ; 127.0.0.0/8 ; ::1
      no_more

    system_aliases:
      driver = redirect
      allow_fail
      allow_defer
      data = MAIL_ALIASES
      user = exim
      file_transport = address_file
      pipe_transport = address_pipe

    userforward:
      driver = redirect
      user = ${user}
      group = ${group}
      local_parts = LOCAL_USERS
      local_part_suffix = +* : -*
      local_part_suffix_optional
      file = ${cfg.usersDir}/''${lc:$local_part}/.forward
      allow_filter
      no_verify
      no_expn
      check_ancestor
      file_transport = address_file
      pipe_transport = address_pipe
      reply_transport = address_reply

    postmaster:
      driver = redirect
      local_parts = root:postmaster
      data = ${cfg.postmaster}@$primary_hostname

    localuser:
      driver = accept
      local_parts = LOCAL_USERS
      local_part_suffix = +* : -*
      local_part_suffix_optional
      transport = local_delivery
      router_home_directory =
      cannot_route_message = Unknown user

    begin transports
    remote_smtp:
      driver = smtp

    local_delivery:
      driver = appendfile
      current_directory = ${cfg.usersDir}/''${lc:$local_part}
      maildir_format = true
      directory = ${cfg.usersDir}/''${lc:$local_part}/Maildir\
        ''${if eq{$local_part_suffix}{}{}\
        {/.''${substr_1:$local_part_suffix}}}
      maildirfolder_create_regex = /\.[^/]+$
      delivery_date_add
      envelope_to_add
      return_path_add
      directory_mode = 0770
      mode = 0660
      user = ${user}
      group = ${group}

    address_pipe:
      driver = pipe
      return_output

    address_file:
      driver = appendfile
      delivery_date_add
      envelope_to_add
      return_path_add

    address_reply:
      driver = autoreply

    begin retry
    # Address or Domain    Error       Retries
    # -----------------    -----       -------

    *                      *           F,2h,15m; G,16h,1h,1.5; F,4d,6h

    begin rewrite

    begin authenticators
    PLAIN:
      driver                     = plaintext
      server_set_id              = $auth2
      server_prompts             = :
      server_condition           = ${cfg.plainAuthCondition}
      server_advertise_condition = ''${if def:tls_in_cipher}

    LOGIN:
      driver                     = plaintext
      server_set_id              = $auth1
      server_prompts             = <| Username: | Password:
      server_condition           = ${cfg.loginAuthCondition}
      server_advertise_condition = ''${if def:tls_in_cipher}
  '';

in {

### interface

  options = {
    services.exim = {
      enable = mkOption {
        default = false;
        description = "Whether to enable the exim mail server.";
      };

      postmaster = mkOption {
        default = "root";
        description = "The user that receives postmaster mail.";
      };

      stateDir = mkOption {
        default = "/var/exim";
        description = "The directory exim uses for work and to store mail.";
      };

      usersDir = mkOption {
        default = "/var/users";
        description = "The directory containing home directories of users.";
      };

      configFile = mkOption {
        default = "";
        description = "A full exim configuration file, overriding the one generated from the given options.";
      };

      debug = mkOption {
        default = true;
        description = "Execute exim in debug mode.";
      };

      primaryHostname = mkOption {
        default = "";
        description = "The primary (canonical) hostname, which is the fully qualified official name of the host.";
      };

      localDomains = mkOption {
        default = [ "@" ];
        description = "A list of the local domains.";
      };

      localUsers = mkOption {
        default = "";
        description = ''
          A exim list of local users. It is inserted verbatim
          in exim config, so it can be an exim expression or a simple list.
         '';
      };

      mailAliases = mkOption {
        default = ''''${lookup{$local_part}lsearch{${cfg.stateDir}/etc/aliases}}'';
        description = "Exim expression for looking up mail aliases.";
      };

      relayFromHosts = mkOption {
        default = "localhost : 127.0.0.1";
        description = "A list of hosts that are allowed to use exim as a relay.";
      };

      tlsCertificate = mkOption {
        default = "";
        description = "The filename of the certificate (.crt) to use.";
      };

      tlsPrivatekey = mkOption {
        default = "";
        description = "The filename of the certificate's private key.";
      };

      smtpPorts = mkOption {
        default = "25 : 587";
        description = "The ports to listen for smtp connections.";
      };

      plainAuthCondition = mkOption {
        default = "false";
        description = "Exim config value used for <literal>server_condition</literal> in the plain authenticator.";
      };

      loginAuthCondition = mkOption {
        default = "false";
        description = "Exim config value used in <literal>server_condition</literal> in the login authenticator.";
      };

      perlScript = mkOption {
        default = null;
        description = "An optional perl script to be included in exim config.";
      };

      messageSizeLimit = mkOption {
        default = "30m";
        description = "The message size limit.";
      };
    };
  };


### implementation

  config = mkIf config.services.exim.enable {

    environment.systemPackages = [ pkgs.exim ];
    security.setuidPrograms = [ "exim-${version}" "exim" ];

    users.extraGroups = singleton {
      name = group;
      gid = config.ids.gids.exim;
    };

    users.extraUsers = singleton {
      name = user;
      description = "Exim mail user.";
      uid = config.ids.uids.exim;
      group = group;
    };

    jobs.exim = {
      description = "The Exim mail server.";
      wantedBy = [ "multi-user.target" ];
      after = [ "networking.target" ];
      setuid = "root";

      preStart = ''
        if ! [ -d ${cfg.stateDir}/etc ]; then
          mkdir -p ${cfg.stateDir}/etc
          # todo
          cp ${pkgs.exim}/etc/aliases ${cfg.stateDir}/etc/
        fi
        if ! [ -d ${cfg.stateDir}/mail ]; then
           mkdir -p ${cfg.stateDir}
           chown -R ${user}:${group} ${cfg.stateDir}
        fi
        if ! [ -d ${cfg.usersDir} ]; then
           mkdir -p ${cfg.usersDir}
           chown -R ${user}:${group} ${cfg.usersDir}
        fi
        if ! [ -d ${cfg.stateDir}/spool ]; then
          mkdir -p ${cfg.stateDir}/spool
          chown -R ${user}:${group} ${cfg.stateDir}/spool
        fi
        ${if (cfg.perlScript == null) then "" else ''
        cat > ${cfg.stateDir}/etc/exim.pl <<- "EOF"
        ${cfg.perlScript}
        EOF
        ''}

        cat > ${cfg.stateDir}/etc/exim.conf <<- "EOF"
        ${eximConfig}
        EOF
      '';

      exec="/var/setuid-wrappers/exim-${version} -bd -q1h ${if cfg.debug then "-v -d" else ""} -C ${cfg.stateDir}/etc/exim.conf";
    };
  };
}

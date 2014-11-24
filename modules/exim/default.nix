{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.exim;
  user = "exim";
  group = "exim";
  version = "4.84";
  eximConfig = ''
    primary_hostname = ${cfg.primaryHostname}
    domainlist local_domains = ${cfg.localDomains}
    domainlist relay_to_domains =
    hostlist   relay_from_hosts = ${cfg.relayFromHosts}

    MY_USERS = eike:john

    acl_smtp_rcpt = acl_check_rcpt
    acl_smtp_data = acl_check_data

    tls_advertise_hosts = *
    tls_certificate = ${cfg.tlsCertificate}
    tls_privatekey = ${cfg.tlsPrivatekey}

    daemon_smtp_ports = ${cfg.smtpPorts}

    host_lookup = *
    ignore_bounce_errors_after = 2d
    timeout_frozen_after = 7d

    spool_directory = /var/exim-${version}/spool
    split_spool_directory = true
    check_rfc2047_length = false

    message_size_limit = 30m

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
      data = ''${lookup{$local_part}lsearch{/var/exim-${version}/etc/aliases}}
      user = exim
      file_transport = address_file
      pipe_transport = address_pipe

    userforward:
      driver = redirect
      user = ${user}
      group = ${group}
      local_parts = MY_USERS
      local_part_suffix = +* : -*
      local_part_suffix_optional
      file = /var/exim-${version}/mail/$local_part/.forward
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
      data = eike@$primary_hostname

    localuser:
      driver = accept
      local_parts = MY_USERS
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
      current_directory = /var/exim-${version}/mail/$local_part
      maildir_format = true
      directory = /var/exim-${version}/mail/$local_part\
        ''${if eq{$local_part_suffix}{}{}\
        {/.''${substr_1:$local_part_suffix}}}
      maildirfolder_create_regex = /\.[^/]+$
      #file = /var/mail/$local_part
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
      server_condition           = Authentication is not yet configured
      server_advertise_condition = ''${if def:tls_in_cipher}

    LOGIN:
      driver                     = plaintext
      server_set_id              = $auth1
      server_prompts             = <| Username: | Password:
      server_condition           = Authentication is not yet configured
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
        default = "@";
        description = "A list of the local domains.";
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
        if ! [ -d /var/exim-${version}/etc ]; then
          mkdir -p /var/exim-${version}/etc
          # todo
          cp ${pkgs.exim}/etc/aliases /var/exim-${version}/etc/
        fi
        if ! [ -d /var/exim-${version}/mail ]; then
           mkdir -p /var/exim-${version}/mail/eike
           chown -R ${user}:${group} /var/exim-${version}/mail
        fi
        if ! [ -d /var/exim-${version}/spool ]; then
          mkdir -p /var/exim-${version}/spool
          chown -R ${user}:${group} /var/exim-${version}/spool
        fi

        cat > /var/exim-${version}/etc/exim.conf <<- "EOF"
        ${eximConfig}
        EOF
      '';

      exec="/var/setuid-wrappers/exim-${version} -bd -q1h ${if cfg.debug then "-v -d" else ""} -C /var/exim-${version}/etc/exim.conf";
    };
  };
}

{ config, pkgs, lib, ... }:
with config;
let
  shelterHttpPort = builtins.toString config.services.shelter.httpPort;
  shelterDb = config.services.shelter.databaseFile;
  shelterAuth = "${pkgs.shelter}/bin/shelter_auth";
  eximCfg = config.services.exim;
  checkPassword = ''
     #!/bin/sh

     REPLY="$1"
     INPUT_FD=3
     ERR_FAIL=1
     ERR_NOUSER=3
     ERR_TEMP=111

     read -d ''$'\x0' -r -u $INPUT_FD USER
     read -d ''$'\x0' -r -u $INPUT_FD PASS

     [ "$AUTHORIZED" != 1 ] || export AUHORIZED=2

     if [ "$CREDENTIALS_LOOKUP" = 1 ]; then
       exit $ERR_FAIL
     else
       if ${shelterAuth} localhost:${shelterHttpPort} $USER $PASS mail; then
           exec $REPLY
       else
           exit $ERR_FAIL
       fi
     fi
    '';
  checkpasswordScript = pkgs.writeScript "checkpassword-dovecot.sh" checkPassword;
  subdomain = "webmail";
in
{
  imports =
    [ ./spam.nix ];

  services.exim = {
    enable = settings.enableMailServer;
    primaryHostname = settings.primaryDomain;
    localDomains = [ "@" "localhost" ("lists."+settings.primaryDomain) ];
    postmaster = "eike";

    moreRecipientAcl = ''
     accept  local_parts = ''${lookup sqlite {${shelterDb} \
                select login from shelter_account_app where login = '$local_part' and appid = 'mailinglist';}}
             domains = ${"lists."+settings.primaryDomain}
    '';

    dataAcl = ''
     # Do not scan messages submitted from our own hosts
     # and locally submitted messages. Since the DATA ACL
     # is not called for messages not submitted via SMTP
     # protocols, we do not need to check for an empty
     # host field.
     accept  hosts = 127.0.0.1:+relay_from_hosts

     # put headers in all messages (no matter if spam or not)
     warn  spam = nobody:true
           condition = ''${if <{$message_size}{80k}{1}{0}}
           add_header = X-Spam-Score: $spam_score ($spam_bar)
           add_header = X-Spam-Report: $spam_report

     # add second subject line with *SPAM* marker when message
     # is over threshold
     warn  spam = nobody
           add_header = Subject: [**SPAM**] $h_Subject:

     # reject spam at scores > 8
     deny  message = This message scored $spam_score spam points.
           spam = nobody:true
           condition = ''${if >{$spam_score_int}{80}{1}{0}}

     accept
    '';

    moreRouters = ''
    allusers:
      driver = redirect
      local_parts = all-users
      domains = lists.${settings.primaryDomain}
      data = ''${lookup sqlite {${shelterDb} \
                    select distinct login from shelter_account_app where appid = 'mail';}}
      forbid_pipe
      forbid_file
      errors_to = ${eximCfg.postmaster}@${settings.primaryDomain}
      no_more

    lists:
      driver = redirect
      domains = lists.${settings.primaryDomain}
      file = /var/data/mailinglists/$local_part
      forbid_pipe
      forbid_file
      errors_to = ${eximCfg.postmaster}@${settings.primaryDomain}
      no_more
    '';

    localUsers = ''
     ''${lookup sqlite {${shelterDb} \
         select login from shelter_account_app where login = '$local_part' and appid = 'mail';}}
     '';

    mailAliases = ''
    ''${if eq{$local_part_suffix}{}\
      {''${lookup sqlite {${shelterDb} \
           select login from shelter_alias where loginalias = '$local_part';}}}\
      {''${lookup sqlite {${shelterDb} \
           select login || "$local_part_suffix" from shelter_alias where loginalias = '$local_part';}}}}
    '';

    plainAuthCondition = ''
      ''${run{${shelterAuth} localhost:${shelterHttpPort} $auth2 $auth3 mail}{true}{false}}
    '';

    loginAuthCondition = ''
      ''${run{${shelterAuth} localhost:${shelterHttpPort} $auth1 $auth2 mail}{true}{false}}
    '';

    tlsCertificate = if (settings.useCertificate) then settings.certificate else "";
    tlsPrivatekey = if (settings.useCertificate) then settings.certificateKey else "";
  };

  services.dovecot2imap = {
    enable = settings.enableMailServer;
#    extraConfig = "mail_debug = yes";
    enableImap = true;
    enablePop3 = true;
    mailLocation = "maildir:${eximCfg.usersDir}/%u/Maildir";
    userDb = ''
      driver = static
      args = uid=exim gid=exim home=${eximCfg.usersDir}/%u
    '';
    passDb = ''
      driver = checkpassword
      args = ${checkpasswordScript}
    '';
    sslServerCert = if (settings.useCertificate) then settings.certificate else "";
    sslServerKey = if (settings.useCertificate) then settings.certificateKey else "";
    sslCACert = if (settings.useCertificate) then settings.caCertificate else "";
  };


  services.roundcube = {
    enable = with settings; enableWebServer && enableMailServer && enableWebmail;
    productName = "eknet webmail";
    supportUrl = (if (settings.useCertificate) then "https://" else "http://") + settings.primaryDomain;
    nginxEnable = true;
    nginxListen = settings.primaryIp + ":" + (if (settings.useCertificate) then "443 ssl" else "80");
    nginxServerName = (subdomain+ "." + settings.primaryDomain);
    nginxFastCgiPass = services.phpfpmExtra.fastCgiBinding;
  };

  services.nginx.httpConfig = if (with settings; enableWebServer && enableMailServer && enableWebmail && useCertificate) then ''
    server {
      listen ${settings.primaryIp}:80;
      server_name ${subdomain}.${settings.primaryDomain};
      return 301 https://${subdomain}.${settings.primaryDomain}$request_uri;
    }
  '' else "";

  services.bindExtra.subdomains = if (settings.enableWebmail) then [ subdomain "lists" ] else [];
  services.shelter.apps = [
    { id = "mail";
      name = "Email";
      url= ((if (settings.useCertificate) then "https://" else "http://")+subdomain+"."+settings.primaryDomain);
      description = "SMTP and IMAP services.";}
    { id = "mailinglist";
      name = "Mailing-Lists";
      url = "";
      description = "Grouping for virtual accounts denoting mailinglists."; }
  ];
}

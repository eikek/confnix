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
       if ${pkgs.curl}/bin/curl -I -s "http://localhost:${shelterHttpPort}/verify?name=$USER&password=$PASS&app=mail" | ${pkgs.gnugrep}/bin/grep "200 OK"; then
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

  services.exim = {
    enable = settings.enableMailServer;
    primaryHostname = settings.primaryDomain;
    localDomains = [ "@" ];
    postmaster = "eike";
    localUsers = ''
     ''${lookup sqlite {${shelterDb} \
         select login from shelter_account_app where login = '$local_part' and appid = 'mail';}}
     '';
    mailAliases = ''
    ''${lookup sqlite {${shelterDb} \
         select login from shelter_alias where loginalias = '$local_part';}}
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

  services.bindExtra.subdomains = if (settings.enableWebmail) then [ subdomain ] else [];
  services.shelter.apps = [{ id = "mail"; name = "SMTP and IMAP services."; }];
}

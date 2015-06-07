{ config, pkgs, lib, ... }:
with config;
with lib;
let
  shelterHttpPort = builtins.toString config.services.shelter.httpPort;
  shelterAuth = "${pkgs.shelter}/bin/shelter_auth";
  ejabberdAuth = pkgs.writeScript "ejabberd-extauth.pl" ''
    #!${pkgs.perl}/bin/perl
    # modified version of https://www.ejabberd.im/files/contributions/check_dovecot.pl.txt
    use Sys::Syslog qw(:standard :macros);

    sub authenticate {
      my $login = shift;
      $login = (split /@/, $login)[0];
      my $passw = shift;
      my $url = "http://localhost:${shelterHttpPort}/api/verify/form";
      syslog LOG_INFO, "doing authentication via shelter at $url with $login";
      my @resp = `${pkgs.curl}/bin/curl -s -D /dev/stdout -o /dev/null --data-urlencode login=$login --data-urlencode password=$passw --data-urlencode app=jabber $url`;
      syslog LOG_INFO, "result: @resp[0]";
      return @resp[0] =~ m{^HTTP.*200 OK};
    }

    sub isuser {
      my $login = shift;
      $login = (split /@/, $login)[0];
      my $url = "http://localhost:${shelterHttpPort}/api/account-exists?login=$login&app=jabber";
      syslog LOG_INFO, "check user existence via shelter at $url with $login";
      my @resp = `${pkgs.curl}/bin/curl -s -D /dev/stdout -o /dev/null $url`;
      syslog LOG_INFO, "result: @resp[0]";
      return @resp[0] =~ m{^HTTP.*200 OK};
    }

    sub setpass {
      my $login = shift;
      my $newpass = shift;
      my $url = "http://localhost:${shelterHttpPort}/api/setpass-force";
      syslog LOG_INFO, "set new password for $login at $url";
      my @resp = `${pkgs.curl}/bin/curl -s -D /dev/stdout -o /dev/null --data-urlencode login=$login --data-urlencode newpassword=$newpass --data-urlencode app=jabber $url`;
      syslog LOG_INFO, "result: @resp[0]";
      return @resp[0] =~ m{^HTTP.*200 OK};
    }

    while (1) {
        my $buf = "";
        syslog("info", "ejabberd-extauth: waiting for packet");
        my $nread = sysread STDIN,$buf,2;
        do { syslog LOG_INFO,"ejabberd-extauth: port closed"; exit; } unless $nread == 2;
        my $len = unpack "n",$buf;
        my $nread = sysread STDIN,$buf,$len;

        my ($op,$user,$domain,$password) = split /:/,$buf;

        # Filter dangerous characters
        $user =~ s/[."\n\r'\$`]//g;
        $password =~ s/[."\n\r'\$`]//g;

        #$user =~ s/\./\//og;
        my $success = false;

        syslog(LOG_INFO,"request ($op, \"$user\@$domain\", '****')");

      SWITCH: {
          $op eq 'auth' and do {
              $success = authenticate($user, $password);
          },last SWITCH;
          $op eq 'setpass' and do {
              $success = setpass($user, $password);
          },last SWITCH;
          $op eq 'isuser' and do {
              $success = isuser($user);
          },last SWITCH;
        };
        if ($success) {
            syslog(LOG_INFO,"-> +OK");
        } else {
            syslog(LOG_INFO,"-> -ERR");
        }
        $rc = $success ? 1 : 0;
        my $out = pack "nn",2,$rc;
        syswrite STDOUT,$out;
    }
    closelog;
  '';
in
{
  config = mkIf config.services.ejabberd15.enable {
    services.ejabberd15 = {
      hosts = [ settings.primaryDomain ];
      externalAuthProgram = ejabberdAuth;
      certfile = if (settings.useCertificate) then settings.certificate else null;
      adminUser = "eike@" + settings.primaryDomain;
    };

    services.shelter.apps = [
      { id = "jabber";
        name = "Jabber";
        url= (if (settings.useCertificate) then "https://" else "http://") + settings.primaryDomain + "/s/jabber/";
        description = "Jabber XMPP chat service.";}
    ];

    networking = {
      firewall = {
        allowedTCPPorts = [ 5222 5269 ];
      };
    };
  };
}

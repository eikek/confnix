{pkgs, config, ...}:
let
   acc = config.accounts."bluecare/hin-id";
in
{
  services.hinclient = {
    enable = true;
    identities = acc.username;
    passphrase = acc.password;
    keystore = /root/ekettne1.hin;
    httpProxyPort = 6016;
    clientapiPort = 6017;
    smtpProxyPort = 6018;
    pop3ProxyPort = 6019;
    imapProxyPort = 6020;
  };
}

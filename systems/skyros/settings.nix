{config, lib, pkgs, ...}:
with lib;
with config;
{
  options = {
    settings = {
      primaryDomain = mkOption {
        default = "eknet.org";
        description = ''The primary domain. Services are configured to this domain.'';
      };

      primaryIp = mkOption {
        default = "188.40.107.134";
        description = ''
          The primary ip address of this machine. It is used to configure
          named server and to bind services to.
        '';
      };

      primaryNameServer = mkOption {
        default = "ns." + config.settings.primaryDomain;
        description = ''The authorative name server name used to configure named.'';
      };

      forwardNameServers = mkOption {
        default = [];
        description = ''The name servers of your provider used to forward requests to.'';
      };

      useCertificate = mkOption {
        default = false;
        description = ''
          Configure all services to use tls/ssl with a certificate. The certficate*
          options must be set. This configures http, smtp, imap and pop3 services to
          use ssl.
        '';
      };

      certificate = mkOption {
        default = "./certs/certificate.crt";
        description = "Path to the ssl certificate.";
      };

      certificateKey = mkOption {
        default = "./certs/certificate_key.key";
        description = "The key to the certificate.";
      };

      caCertificate = mkOption {
        default = "./certs/ca_cert.crt";
        description = "The certificate of the CA.";
      };

      enableBind = mkOption {
        default = true;
        description = ''Enable a local bind server that hosts your <literal>primaryDomain</literal>.'';
      };

      enableMailServer = mkOption {
        default = true;
        description = "Whether to install a smtp/imap/pop3 server.";
      };

      enableWebmail = mkOption {
        default = true;
        description = ''
          Whether to enable roundcube web mail. Only makes sense if <literal>enableWebServer</literal> and
          <literal>enableMailServer</literal> is both true.
        '';
      };

      enableWebServer = mkOption {
        default = true;
        description = "Whether to enable nginx web server.";
      };

    };
  };

  config = {
    services.cron.mailto = "root@${settings.primaryDomain}";

    services.openssh.passwordAuthentication = false;
    services.openssh.forwardX11 = true;
    programs.ssh.setXAuthLocation = true;

    services.nginxExtra = {
      protectedPaths = [{
        path = "/s/pics/family";
        app = "family";
      }{
        path = "/s/pics/harry";
        app = "harry";
        config = ''
          autoindex on;
        '';
      }];
    };

    services.shelter.apps = [{
      id = "family";
      name = "Kjartan Bilder";
      url= ((if (settings.useCertificate) then "https://" else "http://")+ settings.primaryDomain) + "/s/pics/family";
      description = "Kjartan Bilder";
    }{
      id = "harry";
      name = "Harry Bilder";
      url= ((if (settings.useCertificate) then "https://" else "http://")+ settings.primaryDomain) + "/s/pics/harry";
      description = "Harry Bilder";
    }];


    networking = {
      defaultMailServer = {
        domain = settings.primaryDomain;
        hostName = "localhost";
        root = "root@" + settings.primaryDomain;
      };

      firewall = {
        allowedTCPPorts = [ 22 25 587 143 80 443 29418 ];
        allowedUDPPorts = [ 53 ];
      };
    };

    time.timeZone = "UTC";

    users.extraGroups = lib.singleton {
      name = "publet";
      gid = config.ids.gids.publet;
    };

    users.extraUsers = lib.singleton {
      name = "publet";
      uid = config.ids.uids.publet;
      extraGroups = ["publet"];
      description = "Publet daemon user.";
    };

    environment.systemPackages = with pkgs; [
      goaccess
      fetchmail
      leiningen
      scala
      jdk
      clojure
      sig
    ];

    system.activationScripts = {
      datachmod = ''
        mkdir -p /var/data
        chmod 755 /var/data
      '';
    };

  };
}

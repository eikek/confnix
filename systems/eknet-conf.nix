{ config, pkgs, lib, ... }:
let
  shelterHttpPort = builtins.toString config.services.shelter.httpPort;
  shelterDb = config.services.shelter.databaseFile;
  shelterVar = config.services.shelter.baseDir;
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
  fastCgiBinding = "127.0.0.1:9000";
  primaryDomain = "eknet.org";
  primaryIp = "192.168.1.59";
  primaryNameServer = "ns.eknet.org";
  forwardNameServers = [ "192.168.1.1" ];
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-eknet.nix
      ../common.nix
    ];

  boot.loader.grub.devices = [ "/dev/sda" ];

  networking = {
    hostName = "eknet.org";
    nameservers = forwardNameServers;
    wireless = {
      enable = false;
    };

    useDHCP = true;
    wicd.enable = false;
    firewall = {
      allowedTCPPorts = [ 22 25 143 80 443 29418 ];
    };
  };

  time.timeZone = "UTC";

  services.bind = {
    enable = true;
    ipv4Only = true;
    zones = [
      { name = primaryDomain;
        master = true;
        file = import ./simple-zone.nix {
          inherit pkgs lib;
          domain = primaryDomain;
          ip = primaryIp;
          nameserver = [ primaryNameServer ];
          cnames = ["www" "webmail" "dev"];
          arecords = [ "ns" "mail" ];
          mx = [{ domain = "mail"; priority = "10"; }];
        };
      }
      { name = "myperception.de";
        master = true;
        file = import ./simple-zone.nix {
          inherit pkgs lib;
          domain = "myperception.de";
          ip = primaryIp;
          cnames = [ "www" ];
          nameserver = [ primaryNameServer ];
          mx = [{domain = ("mail."+ primaryDomain); priority = "10";}];
        };
      }
    ];
  };

  services.nginx =  {
    enable = true;
    httpConfig = ''
      include       ${pkgs.nginx}/conf/mime.types;
      default_type  application/octet-stream;
      sendfile        on;
      keepalive_timeout  65;

      server {
        listen ${primaryIp}:80;
        server_name www.${primaryDomain} ${primaryDomain};
        root /var/www;
        index index.html index.php;
        location / {
          try_files $uri $uri/ /index.php;
        }
        location ~ \.php$ {
          fastcgi_pass ${fastCgiBinding};
          fastcgi_index index.php;
          include ${pkgs.nginx}/conf/fastcgi_params;
          include ${pkgs.nginx}/conf/fastcgi.conf;
        }
      }
    '';
  };

  services.mongodb = {
    enable = true;
  };


  services.sitebag.enable = true;


  services.gitblit = {
    enable = true;
    httpurlRealm = ''http://localhost:${shelterHttpPort}/verify?name=%[username]&password=%[password]&app=gitblit'';
  };


  services.shelter = {
    enable = true;
    autoLoad = ''
    (in-ns 'shelter.core)
    (add-rest-verify-route)
    (rest/apply-routes)

    (defn- app-add [id name]
      (if (not (account/app-exists? id))
        (account/add-application id name)))

    (app-add "mail"     "SMTP and IMAP services.")
    (app-add "sitebag"  "Sitebag read-it-later")
    (app-add "gitblit"  "Gitblit git solution")

    (if (not (account/resolve-alias "eike"))
      (account/register "eike")
      (account/grant-app "eike" ["mail" "sitebag"]))
    '';
    loadFiles = [ "${shelterVar}/shelterrc.clj" ];
  };

  services.exim = {
    enable = true;
    primaryHostname = "ithaka";
    localDomains = "myperception.de : eknet.org : @";
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
  };

  services.dovecot2imap = {
    enable = true;
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
  };


  services.phpfpm = {
    poolConfigs = {
      mypool = ''
        listen = ${fastCgiBinding}
        user = ${config.services.nginx.user}
        pm = dynamic
        pm.max_children = 75
        pm.start_servers = 5
        pm.min_spare_servers = 2
        pm.max_spare_servers = 20
        pm.max_requests = 500
      '';
    };
    # extraConfig = ''
    # log_level = debug
    # '';
  };

  services.roundcube = {
    enable = true;
    nginxEnable = true;
    nginxServerName = ("webmail." + primaryDomain);
    nginxFastCgiPass = fastCgiBinding;
  };

  hardware = {
    #cpu.intel.updateMicrocode = true;  #needs unfree
  };

}

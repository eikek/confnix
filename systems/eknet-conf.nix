{ config, pkgs, ... }:
let
  shelterHttpPort = builtins.toString config.services.shelter.httpPort;
  shelterDb = config.services.shelter.databaseFile;
  shelterVar = config.services.shelter.baseDir;
  shelterAuth = "${pkgs.shelter}/bin/shelter_auth";
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
    wireless = {
      enable = false;
    };

    useDHCP = true;
    wicd.enable = false;
    firewall = {
      allowedTCPPorts = [ 22 25 80 443 29418 ];
    };
  };

  time.timeZone = "UTC";

  services.mongodb = {
    enable = true;
  };


  services.sitebag.enable = true;
  services.gitblit.enable = true;

  services.shelter = {
    enable = true;
    autoLoad = ''
    (in-ns 'shelter.core)
    (add-rest-verify-route)
    (rest/apply-routes)

    (if (not (account/app-exists? "mail"))
      (account/add-application "mail" "SMTP and IMAP services."))

    (if (not (account/resolve-alias "eike"))
      (account/register "eike")
      (account/grant-app "eike" ["mail"]))
    '';
    loadFiles = [ "${shelterVar}/shelterrc.clj" ];
  };

  services.exim = {
    enable = true;
    primaryHostname = "ithaka";
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

  hardware = {
    #cpu.intel.updateMicrocode = true;  #needs unfree
  };

}

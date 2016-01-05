{ config, pkgs, ... }:
let
  jdk7env = (import ../../jdk7env.nix) { inherit pkgs; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-shang.nix
      ../../common-desktop.nix
    ];

  boot = {
    loader = {
      gummiboot.enable = true;
      gummiboot.timeout = 5;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_4_2;
    initrd.kernelModules = [ "nouveau" "fbcon" ];
  };

  virtualisation.virtualbox.host.enable = true;

  networking = {
    hostName = "shang";
    hostId = "b43f128a";
    wireless = {
      enable = false;
    };
    useDHCP = true;
    wicd.enable = false;
    firewall = {
      allowedTCPPorts = [ 8080 ];
    };

#    nat = {
#      enable = true;
#      externalInterface = "enp3s0";
#      internalInterfaces = [ "ve-+" ];
#    };
  };

  # needed for the `user` option below
  security.setuidPrograms = [ "mount.cifs" ];

  fileSystems = let
   serverpass = if (builtins.tryEval <serverpass>).success then
     builtins.readFile <serverpass>
     else builtins.throw ''Please specify a file that contains the
       password to mount the fileserver and add it to the NIX_PATH
       variable with key "serverpass".
     '' ;
  in {
    "/home/fileserver" = {
      device = "//fileserver/daten";
      fsType = "cifs";
      options = "user=ekettner,password=${serverpass},uid=eike,user";
    };
  };

  services.nginx = {
    httpConfig = ''
      ssl_session_cache    shared:SSL:10m;
      ssl_session_timeout  10m;
      ssl_certificate      /root/wildcard.tocco.ch.2014.sha2.pem;
      ssl_certificate_key  /root/wildcard.tocco.ch.2014.sha2.key;
      ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
      ssl_ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS;
      ssl_prefer_server_ciphers   on;

      server {
        listen 443 ssl;
        listen 80;
        server_name ek.tocco.ch;
        location /home {
          alias /home/eike/public_html/;
        }
        location / {
          proxy_pass http://127.0.0.1:8080;
          proxy_set_header X-Forwarded-For   $remote_addr;
          proxy_set_header Host              $host;
          proxy_set_header X-Forwarded-Proto $scheme;
        }
      }
    '';
  };

  # Enable the X11 windowing system.
  services.xserver = {
    videoDrivers = [ "nouveau" ];
  };

  services.postgresql = {
    enable = true;
    #dataDir = "/data/postgresql/data-9.4";
    package = pkgs.postgresql94;
    extraConfig = ''
      track_activities = true
      shared_buffers = 2GB
      maintenance_work_mem = 2GB
      fsync = off
      synchronous_commit = off
      wal_level = minimal
      full_page_writes = off
      wal_buffers = 64MB
      max_wal_senders = 0
      wal_keep_segments = 0
      archive_mode = off
      autovacuum = off
    '';
  };

  environment.pathsToLink = [ "/" ];

  environment.systemPackages = [
    jdk7env
  ];

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = false;
    cpu.intel.updateMicrocode = true;  #needs unfree
    opengl.driSupport32Bit = true;
  };

  services.printing = {
    drivers = [ pkgs.hl5380ppd ];
  };

}

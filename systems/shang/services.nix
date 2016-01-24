{ config, pkgs, ... }:
let
  jdk7env = (import ../../jdk7env.nix) { inherit pkgs; };
in
{
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
          proxy_read_timeout 120m;
          proxy_send_timeout 120m;
        }
      }
    '';
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql95;
    extraConfig = ''
      track_activities = true
      shared_buffers = 2GB
      maintenance_work_mem = 2GB
      work_mem = 16MB
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

  services.printing = {
    drivers = [ pkgs.hl5380ppd ];
  };
}

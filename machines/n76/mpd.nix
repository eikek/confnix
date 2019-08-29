{pkgs, config, ...}:
let
  accounts = if (builtins.tryEval (import <accounts>)).success then
     import <accounts>
     else builtins.throw ''Please specify a accounts.nix file that
       contains the accounts that are setup here. You can generate the
       file using the pass2accounts.sh script. '' ;
in
{

  services.mpd = {
    enable = true;
    musicDirectory = "/home/music";
    extraConfig = ''
      max_connections "15"
      audio_output {
        type "alsa"
        name "FIIO X5"
        device "iec958:CARD=X5,DEV=0"
      }
    '';
  };

  services.mpdscribble =
  let
    acc = "internet/libre.fm";
  in
  {
    enable = true;
    mpdHost = config.services.mpd.network.listenAddress;
    mpdPort = config.services.mpd.network.port;
    accounts = {
      librefm = {
        url = "http://turtle.libre.fm";
        user = accounts.${acc}.username;
        pass = accounts.${acc}.password;
      };
      attentive = {
        url = "https://attentive.daheim.site/scrobble";
        user = accounts.${acc}.username;
        pass = accounts.${acc}.password;
      };
    };
  };

  services.mpc4s = {
    enable = true;
    userService = true;
    musicDirectory = "/home/music";
    mpdConfigs = {
      default = {
        host = "127.0.0.1";
        port = 6600;
        max-connections = 10;
        title = "N76";
      };
    };
    coverThumbDir = "/home/eike/.mpd/thumbnails";
    bindHost = "localhost";
    bindPort = 9600;
  };

}

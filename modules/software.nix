{ config, pkgs, ... }:
with pkgs.lib;
{

  options = {
    software = {
      base = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          cifs-utils
          fzf
          git-crypt
          git-lfs
          mr
          nix-prefetch-scripts
          pass
          pinentry
          recutils
          rlwrap
          sqlite
          tmuxinator
          wpa_supplicant
          stow
        ];
      };

      image = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          feh
          gimp
          gnuplot
          graphviz
          imagemagick
          gifsicle
          jhead
          libjpeg
          plantuml
          viewnior
          inkscape
          shutter
        ];
      };

      multimedia = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          alsaUtils
          cdparanoia
          ffmpeg
          flac
          mediainfo
          mpv
          sox
          vorbis-tools
        ];
      };

      xorg = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          alacritty
          autorandr
          chromium
          dmenu
          firefox
          i3lock
          i3lock-fancy
          polybar
          qutebrowser
          scrot
          signal-desktop
          threema-desktop
          xclip
          xdotool
          xorg.xdpyinfo
          xorg.xmodmap
          xorg.xrandr
          xorg.xwd
          xorg.xwininfo
          xsel
        ];
      };

      devel =
        let
          myR = pkgs.rWrapper.override {
            packages = with pkgs.rPackages;
              [
                ggplot2
              ];
          };
        in
        mkOption
          {
            type = types.listOf types.package;
            default = with pkgs; [
              myR
              nodePackages.bash-language-server
              bloop
              coursier
              global
              guile
              gradle
              nodejs
              jetbrains.idea-community
              inotify-tools
              openscad
              postgresql
              python3
              ripgrep
              sbcl
              scala-cli
              silver-searcher
              visualvm
              yarn
            ];
          };

      tools = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          dsc
          ghostscript
          (hunspellWithDicts [ "de_DE" "de_CH" "en_US-large" "en_GB-large" ])
          hunspellDicts."de_DE"
          hunspellDicts."en_GB-large"
          hunspellDicts."en_US-large"
          localsend
          mu
          mu.mu4e
          offlineimap
          pandoc
          peek
          recutils
          sqlitebrowser
          tesseract4
          unpaper
          python3Packages.weasyprint
          unoconv
          yt-dlp
          zathura
          ocrmypdf
          q-text-as-data
        ];
      };

      extra = mkOption {
        type = types.listOf types.package;
        default = [ ];
      };

      blacklist = mkOption {
        type = types.listOf types.package;
        default = [ ];
      };

    };
  };


  config = {
    environment.systemPackages =
      let
        ff = p: ! builtins.elem p config.software.blacklist;
        all = config.software.base ++
          config.software.image ++
          config.software.multimedia ++
          config.software.xorg ++
          config.software.devel ++
          config.software.tools ++
          config.software.extra;
      in
      builtins.filter ff all;
  };
}

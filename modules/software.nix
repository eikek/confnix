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
          pinentry-gnome3
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
          alsa-utils
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
          rofi
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
          xdpyinfo
          xmodmap
          xrandr
          xwd
          xwininfo
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
              bash-language-server
              coursier
              global
              guile
              gradle
              nodejs
              jetbrains.idea-oss
              inotify-tools
              openscad
              postgresql
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
          #dsc
          ghostscript
          (hunspell.withDicts (d: [ d."de_DE" d."de_CH" d."en_US-large" d."en_GB-large" ]))
          # hunspellDicts."de_DE"
          # hunspellDicts."en_GB-large"
          # hunspellDicts."en_US-large"
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

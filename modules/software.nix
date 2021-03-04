{ config, pkgs, ... }:
with pkgs.lib;
{

  options = {
    software = {
      base = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          cifs_utils
          direnv
          fzf
          git-crypt
          mr
          nix-prefetch-scripts
          nixops
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
          vorbisTools
        ];
      };

      xorg = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          alacritty
          autorandr
          chromium
          firefox
          i3lock
          i3lock-fancy
          qutebrowser
          scrot
          xclip
          xlibs.xdpyinfo
          xlibs.xmodmap
          xlibs.xrandr
          xlibs.xwd
          xorg.xwininfo
          xsel
          polybar
          dmenu
        ];
      };

      devel = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          R
          ammonite-repl
          nodePackages.bash-language-server
          clojure
          elmPackages.elm
          elmPackages.elm-analyse
          elmPackages.elm-format
          elmPackages.elm-language-server
          elmPackages.elm-live
          elmPackages.elm-test
          elmPackages.elm-xref
          global
          guile
          gradle
          nodejs
          idea.idea-community
          inotify-tools
          leiningen
          nodejs
          mariadb
          maven
          openscad
          postgresql_12
          purescript
          python
          sbcl
          sbt
          scala
          silver-searcher
          spago
          visualvm
        ];
      };

      tools = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          direnv
          docspell.tools
          ghostscript
          mu
          offlineimap
          pandoc
          peek
          recutils
          sqlitebrowser
          tesseract_4
          unpaper
          wkhtmltopdf
          unoconv
          youtube-dl
          zathura
          ocrmypdf
        ];
      };

      extra = mkOption {
        type = types.listOf types.package;
        default = [];
      };

      blacklist = mkOption {
        type = types.listOf types.package;
        default = [];
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

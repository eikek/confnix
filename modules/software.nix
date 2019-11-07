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
          jhead
          libjpeg
          plantuml
          viewnior
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
          firefox-esr
          i3lock
          i3lock-fancy
          qutebrowser
          scrot
          stumpish
          xclip
          xlibs.xdpyinfo
          xlibs.xmodmap
          xlibs.xrandr
          xlibs.xwd
          xorg.xwininfo
          xsel
        ];
      };

      devel = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          R
          ammonite-repl
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
          idea.idea-community
          leiningen
          mariadb
          maven
          postgresql_11
          python
          sbcl
          sbt
          scala
          silver-searcher
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
          sqliteman
          tesseract_4
          unpaper
          youtube-dl
          zathura
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

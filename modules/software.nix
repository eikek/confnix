{ config, pkgs, ... }:
with pkgs.lib;
{

  options = {
    software = {
      base = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          cifs-utils
          direnv
          fzf
          git-crypt
          git-lfs
          mr
          nix-prefetch-scripts
#          nixops
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
              [ ggplot2
              ];
          };
          sbt8 =
            pkgs.writeShellScriptBin "sbt8" ''
              export SBT_OPTS="-Xms512M -Xmx4G -Xss32M -Duser.timezone=GMT"
              ${pkgs.sbt8}/bin/sbt "$@"
           '';
          sbt11 =
            pkgs.writeShellScriptBin "sbt11" ''
              export SBT_OPTS="-Xms512M -Xmx4G -Xss32M -Duser.timezone=GMT"
              ${pkgs.sbt11}/bin/sbt "$@"
           '';
        in
        mkOption
        {
          type = types.listOf types.package;
          default = with pkgs; [
            myR
            ammonite
            nodePackages.bash-language-server
            bloop
            cargo
            clippy
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
            jetbrains.idea-community
            inotify-tools
            leiningen
            nodejs
            mariadb
            maven
            openscad
            postgresql
            purescript
            python3
            ripgrep
            rust-analyzer
            rustfmt
            rustup
            sbcl
            sbt
            sbt8
            sbt11
            scala
            silver-searcher
            spago
            visualvm
            yarn
          ];
        };

      tools = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          direnv
          dsc
          ghostscript
          (hunspellWithDicts [ "de_DE" "de_CH" "en_US-large" "en_GB-large" ])
          hunspellDicts."de_DE"
          hunspellDicts."en_GB-large"
          hunspellDicts."en_US-large"
          localsend
          mu
          offlineimap
          pandoc
          peek
          recutils
          sqlitebrowser
          tesseract4
          unpaper
          python3Packages.weasyprint
          unoconv
          youtube-dl
          zathura
          ocrmypdf
          q-text-as-data
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
    nixpkgs.config.permittedInsecurePackages = [
      "python2.7-urllib3-1.26.2"
      "python2.7-pyjwt-1.7.1"
    ];

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

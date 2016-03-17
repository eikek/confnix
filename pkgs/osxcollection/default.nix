pkgs:
with pkgs;
let
  # see https://nixos.org/wiki/TexLive_HOWTO
  tex = texlive.combine {
    inherit (texlive) scheme-medium collection-latexextra beamer moderncv moderntimeline cm-super inconsolata libertine;
  };
  xplantuml = import ./plantuml.nix { inherit stdenv fetchurl graphviz; jre = jdk8; };
in
buildEnv {
  name = "osxcollection";
  paths = [
    R
    cask
    coreutils
    curl
    emacs
    feh
    flac
    vorbisTools
    ffmpeg
    fswatch
    ghostscript
    gitAndTools.gitFull
    gitAndTools.gitflow
    global
    gnupg1compat
    gnuplot
    graphviz
    guile
    htop
    imagemagick
    jhead
    jhead
    libjpeg
    libogg
    mpg123
    mr
    nix-prefetch-scripts
    nix-repl
    offlineimap
    pandoc
    pass
    qemu
    rlwrap
    silver-searcher
    tex
    tmux
    vcsh
    xplantuml
    zsh
#    mu
  ];
}

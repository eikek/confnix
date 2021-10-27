# from https://nixos.org/nixos/manual/index.html#module-services-emacs

{ pkgs ? import <nixpkgs> {} }:

let
  spinner-lzip = builtins.fetchurl {
    url = "https://elpa.gnu.org/packages/spinner-1.7.3.el.lz";
    sha256 = "188i2r7ixva78qd99ksyh3jagnijpvzzjvvx37n57x8nkp8jc4i4";
  };
  excorporate-tar = builtins.fetchurl {
    url = "https://elpa.gnu.org/packages/excorporate-1.0.0.tar";
    sha256 = "088i2r7ixva78qd99ksyh3jagnijpvzzjvvx37n57x8nkp8jc401";
  };
  org-tar = builtins.fetchurl {
    url = "https://elpa.gnu.org/packages/org-9.5.tar";
    sha256 = "16cflg5nms5nb8w86nvwkg49zkl0rvdhigkf4xpvbs0v7zb5y3ky";
  };
  org-contrib-tar = builtins.fetchurl {
    url = "https://orgmode.org/elpa/org-plus-contrib-20210920.tar";
    sha256 = "16cflg5nms5nb8w86nvwkg49zkl0rvdhigkf4xpvbs0v7zb5y3k0";
  };

  emacsOverrides = self: super: rec {
    spinner = super.spinner.override {
      elpaBuild = args: super.elpaBuild (args // {
        src = pkgs.runCommandLocal "spinner-1.7.3.el" {} ''
          ${pkgs.lzip}/bin/lzip -d -c ${spinner-lzip} > $out
        '';
      });
    };

    excorporate = super.excorporate.override {
      elpaBuild = args: super.elpaBuild (args // {
        src = excorporate-tar;
      });
    };

    org = super.org.override {
      elpaBuild = args: super.elpaBuild (args // {
        src = org-tar;
      });
    };
    org-plus-contrib = super.orgPackages.org-plus-contrib.override {
      elpaBuild = args: super.elpaBuild (args // {
        version = "20210920";
        src = pkgs.fetchurl {
          url = "https://orgmode.org/elpa/org-plus-contrib-20210920.tar";
          sha256 = "0g765fsc7ssn779xnhjzrxy1sz5b019h7dk1q26yk2w6i540ybf0";
        };

      });
    };
  };

  myEmacs = pkgs.emacs.override {
    withXwidgets = true;
  };
  emacsPackagesNg = (pkgs.emacsPackagesNgGen myEmacs).overrideScope' emacsOverrides;
  emacsWithPackages = emacsPackagesNg.emacsWithPackages;
  customPackages = import ./extras.nix { inherit pkgs emacsPackagesNg; };
in
  emacsWithPackages (epkgs: customPackages ++ (with epkgs.melpaStablePackages; [
  ]) ++ (with epkgs.orgPackages; [

#    org-plus-contrib

  ]) ++ (with epkgs.elpaPackages; [

    rainbow-mode
#    auctex
#    excorporate

  ]) ++ (with epkgs.melpaPackages; [
    use-package
    diminish
    dash
    s
    f
    hydra

    buffer-move
    eyebrowse
    rainbow-delimiters
    hide-lines

    company
#    company-auctex
    company-nixos-options
    company-quickhelp

    ivy
    ivy-hydra
    counsel
    swiper

    which-key
    golden-ratio
    nyan-mode
    keycast

#    moody
    minions
    autumn-light-theme
    badger-theme
    boron-theme
    darktooth-theme
    doom-themes
    darcula-theme
    doom-modeline
    eziam-theme
    gruvbox-theme
    leuven-theme
    reykjavik-theme
    sexy-monochrome-theme
    soft-charcoal-theme
    soft-stone-theme
    solarized-theme
    spacemacs-theme
    sublime-themes
    zenburn-theme
    all-the-icons
    all-the-icons-ivy
    all-the-icons-dired

    magit
    forge
    git-gutter
    git-gutter-fringe
    git-timemachine

    htmlize
    restclient

    org-bullets
    org-tree-slide
    org-journal
#    org-jira
    ob-restclient
    ob-elvish
    ob-mongo
    ob-rust
    ox-asciidoc
    ox-gfm
    ox-jira
    ox-pandoc
    ox-twbs
    counsel-org-clock

    projectile
    counsel-projectile

    dired-subtree
    dired-rainbow
    dired-filter
    editorconfig
    stripe-buffer
    whitespace-cleanup-mode
    move-text
    yasnippet
    expand-region
    multiple-cursors
    paredit
    ggtags
    emmet-mode
    web-mode
    adoc-mode
    yaml-mode
    sass-mode
    goto-chg
#    geiser
    markdown-mode
    flymd
    flycheck
    flycheck-rust
    plantuml-mode
    groovy-mode
    kotlin-mode
    flycheck-kotlin
    js2-mode
    scala-mode
    sbt-mode
    elm-mode
    clojure-mode
    rustic
    elvish-mode
    monroe
    cider
    slime
    nix-mode
    ess
    stumpwm-mode
    password-store
    pass
    magnatune
    chee
    dictcc
    elfeed
    beacon
    nameless
    logview
    scad-mode
    ansible
    fish-mode
    treemacs
#    dap-mode
    eglot
    vterm
    vterm-toggle
    solaire-mode
#    gif-screencast
    clipetty
    exec-path-from-shell
    fish-completion
    eshell-git-prompt
    vue-mode
    vue-html-mode
    docker
    docker-compose-mode
    dockerfile-mode
    impatient-mode
    purescript-mode
    psci
    psc-ide
    dhall-mode
#    haskell-mode
#    nix-haskell-mode
#    lsp-haskell
    dashboard
    visual-fill-column
    fill-column-indicator
    hl-fill-column
    edit-server
    polymode
    poly-markdown
    poly-R
    direnv
  ]))

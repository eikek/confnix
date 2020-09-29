# from https://nixos.org/nixos/manual/index.html#module-services-emacs

{ pkgs ? import <nixpkgs> {} }:

let
  myEmacs = pkgs.emacs.override {
    withXwidgets = true;
  };
  emacsPackagesNg = (pkgs.emacsPackagesNgGen myEmacs);
  emacsWithPackages = emacsPackagesNg.emacsWithPackages;
  customPackages = import ./extras.nix { inherit pkgs emacsPackagesNg; };
in
  emacsWithPackages (epkgs: customPackages ++ (with epkgs.melpaStablePackages; [
  ]) ++ (with epkgs.orgPackages; [

    org-plus-contrib

  ]) ++ (with epkgs.elpaPackages; [

    rainbow-mode
    auctex
    excorporate
    hyperbole

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
    company-auctex
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
    org-jira
    ob-restclient
    ob-elvish
    ob-mongo
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
    geiser
    markdown-mode
    flymd
    flycheck
    plantuml-mode
    groovy-mode
    js2-mode
    scala-mode
    sbt-mode
    elm-mode
    clojure-mode
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
    slack
    play-routes-mode
    logview
    scad-mode
    ansible
    fish-mode
    lsp-mode
    lsp-java
    lsp-ui
    lsp-treemacs
    treemacs
    company-lsp
    dap-mode
    vterm
    vterm-toggle
    solaire-mode
    gif-screencast
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
    haskell-mode
    nix-haskell-mode
    lsp-haskell
    dashboard
  ]))

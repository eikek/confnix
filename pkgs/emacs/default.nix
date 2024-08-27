# from https://nixos.org/nixos/manual/index.html#module-services-emacs

{ pkgs }:

let
  # spinner-lzip = builtins.fetchurl {
  #   url = "https://elpa.gnu.org/packages/spinner-1.7.3.el.lz";
  #   sha256 = "188i2r7ixva78qd99ksyh3jagnijpvzzjvvx37n57x8nkp8jc4i4";
  # };
  # org-tar = builtins.fetchurl {
  #   url = "https://elpa.gnu.org/packages/org-9.5.2.tar";
  #   sha256 = "12pvr47b11pq5rncpb3x8y11fhnakk5bi73j9l9w4d4ss3swcrnh";
  # };
  # org-contrib-tar = builtins.fetchurl {
  #   url = "https://orgmode.org/elpa/org-plus-contrib-20210929.tar";
  #   sha256 = "16cflg5nms5nb8w86nvwkg49zkl0rvdhigkf4xpvbs0v7zb50000";
  # };

  emacsOverrides = self: super: rec {
    # spinner = super.spinner.override {
    #   elpaBuild = args: super.elpaBuild (args // {
    #     src = pkgs.runCommandLocal "spinner-1.7.3.el" {} ''
    #       ${pkgs.lzip}/bin/lzip -d -c ${spinner-lzip} > $out
    #     '';
    #   });
    # };
    # org = super.org.override {
    #   elpaBuild = args: super.elpaBuild (args // {
    #     src = org-tar;
    #   });
    # };
    # org-plus-contrib = super.orgPackages.org-plus-contrib.override {
    #   elpaBuild = args: super.elpaBuild (args // {
    #     version = "20210920";
    #     src = pkgs.fetchurl {
    #       url = "https://orgmode.org/elpa/org-plus-contrib-20210920.tar";
    #       sha256 = "0g765fsc7ssn779xnhjzrxy1sz5b019h7dk1q26yk2w6i540ybf0";
    #     };

    #   });
    # };
  };

  myEmacs = pkgs.emacs29;
  emacsPackages = (pkgs.emacsPackagesFor myEmacs).overrideScope emacsOverrides;
  emacsWithPackages = emacsPackages.emacsWithPackages;

  eaf = import ./eaf.nix { inherit pkgs emacsPackages; };
  extras = import ./extras.nix { inherit pkgs emacsPackages; };
  customPackages = extras ++ [ eaf.elisp pkgs.ds4e ];

  # binary packages that are brought into emacs' scope
  binPackages = eaf.binaryPackages ++ [ pkgs.multimarkdown ];

  # additional env variables to set
  envVars = eaf.env // {
    JAVA_HOME = "${pkgs.jdk17}/lib/openjdk";
  };

  myEmacsWithPkgs =
    emacsWithPackages
      (epkgs: customPackages ++
        (with epkgs; [
          svg-tag-mode
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
          sqlite3

          rainbow-mode
          auctex

          company
          company-auctex
          company-nixos-options
          company-quickhelp
          orderless

          consult
          consult-dir
          consult-company
          consult-flycheck
          consult-projectile
          consult-yasnippet
          consult-lsp
          embark
          embark-consult
          marginalia
          vertico
          wgrep

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
          gruvbox-theme
          leuven-theme
          reykjavik-theme
          sexy-monochrome-theme
          soft-charcoal-theme
          soft-stone-theme
          solarized-theme
          stimmung-themes
          spacemacs-theme
          sublime-themes
          zenburn-theme
          kaolin-themes
          inkpot-theme
          modus-themes
          humanoid-themes
          all-the-icons
          all-the-icons-ivy
          all-the-icons-dired
          nerd-icons
          nerd-icons-dired

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
          org-modern
          ob-restclient
          ob-elvish
          ob-mongo
          ob-rust
          ox-asciidoc
          ox-gfm
          counsel-org-clock

          projectile
          counsel-projectile

          dired-subtree
          dired-rainbow
          dired-filter
          dired-ranger
          dired-sidebar
          dirvish
          editorconfig
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
          geiser-guile
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
          clojure-ts-mode
          sparql-mode
          rustic
          elvish-mode
          monroe
          cider
          slime
          nix-mode
          nix-ts-mode
          ess
          stumpwm-mode
          password-store
          pass
          magnatune
          chee
          dictcc
          beacon
          nameless
          logview
          scad-mode
          ansible
          fish-mode
          treemacs
          vterm
          vterm-toggle
          solaire-mode
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
          lsp-metals
          lsp-mode
          lsp-java
          lsp-ui
          lsp-treemacs
          lsp-pyright
          lsp-bridge
          poetry
          # ruff-format
          # lazy-ruff
          dashboard
          visual-fill-column
          fill-column-indicator
          edit-server
          polymode
          poly-markdown
          poly-R
          envrc
          imenu-list
          imenu-extra
          rfc-mode
          ement
          burly
          kubernetes
          pdf-tools

        ]) ++
        (with epkgs.melpaStablePackages; [

        ]) ++
        (with epkgs.nongnuPackages; [

          org-contrib

        ]) ++ (with epkgs.elpaPackages; [


      ]) ++ (with epkgs.melpaPackages; [
      ]));
in
pkgs.symlinkJoin {
  name = "my-emacs";
  meta.mainProgram = "emacs";
  paths = [ myEmacsWithPkgs ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild =
    let
      envSet =
        builtins.concatStringsSep " "
          (builtins.concatLists (pkgs.lib.mapAttrsToList (name: value: [ "--set" name ''"${value}"'' ]) envVars));
    in
    ''
      wrapProgram $out/bin/emacs --prefix PATH : "${pkgs.lib.makeBinPath (binPackages)}" ${envSet}
    '';
}

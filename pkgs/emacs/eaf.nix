{ pkgs, emacsPackages }:
let
  pyDeps = with pkgs; python3.withPackages (p: [
    p.pandas
    p.requests
    p.sexpdata
    p.tld
    p.pyqt6
    p.pyqt6-sip
    p.pyqt6-webengine
    p.epc
    p.lxml # for eaf
    #p.qrcode # eaf-file-browser
    p.pysocks # eaf-browser
    p.pymupdf # eaf-pdf-viewer
    p.packaging # eaf-pdf-viewer
    #p.pypinyin # eaf-file-manager
    #p.psutil # eaf-system-monitor
    # eaf-markdown-previewer
    p.retry
    p.markdown
    p.retrying
  ]);

in
{

  elisp = pkgs.stdenvNoCC.mkDerivation {
    name = "eaf-0.0.1";

    src = pkgs.fetchFromGitHub {
      owner = "emacs-eaf";
      repo = "emacs-application-framework";
      rev = "46733de03bcd9f20c54747753aa4fd2669f7b4ce";
      sha256 = "sha256-5/oV93RmytyxRKMHVzpcdb6XusoO1KRFlscPKaNsgIo=";
    };

    browserJS = pkgs.buildNpmPackage rec {
      pname = "eaf-browser";
      version = "1c0076";
      src = pkgs.fetchFromGitHub {
        owner = "emacs-eaf";
        repo = "eaf-browser";
        rev = "1c0076cca287c384f46e5104365f679e94135734";
        sha256 = "sha256-VyDwQiYfeEhIEpsl2Tw5hdspNFPC3I9jeSrp80G8IPo=";
      };
      npmDepsHash = "sha256-MUf+fJdEfzU/0e4he7mVURE1osP+Jm28LduCEtcJAPg=";
      dontNpmBuild = true;

      installPhase = ''
        npm install

        mkdir $out
        cp -r * $out/
      '';
    };

    pdfviewer = pkgs.stdenvNoCC.mkDerivation rec {
      version = "ea467c";
      name = "eaf-pdf-viewer-${version}";

      src = pkgs.fetchFromGitHub {
        owner = "emacs-eaf";
        repo = "eaf-pdf-viewer";
        rev = "ea467c4fed134b30d5b11a6b83900bd3bb87dc32";
        sha256 = "sha256-jcZgW0faOqEB2xejeT5fkpMaUVHYyZPKQ45Fs3K2kgc=";
      };
      buildPhase = "true";
      installPhase = ''
        mkdir $out
        cp -r * $out/
      '';
    };

    orgpreviewJS = pkgs.buildNpmPackage rec {
      pname = "eaf-org-previewer";
      version = "e6e6d3";
      src = pkgs.fetchFromGitHub {
        owner = "emacs-eaf";
        repo = "eaf-org-previewer";
        rev = "e6e6d3c1b227a395d530d5d0fc6e42e0a6a11ed8";
        sha256 = "sha256-ZvuJej98O3OMLGxTvZd+7x/cpjD2s1aaMNkS3IGbAII=";
      };
      npmDepsHash = "sha256-tjPKmbkzFoMKOQcnBfqEZz2k0IHWg3E/xOtZSlMsjmE=";
      dontNpmBuild = true;

      installPhase = ''
        npm install

        mkdir $out
        cp -r * $out/
      '';
    };

    markdownpreviewJS = pkgs.buildNpmPackage rec {
      pname = "eaf-markdown-previewer";
      version = "a16b6d";
      src = pkgs.fetchFromGitHub {
        owner = "emacs-eaf";
        repo = "eaf-markdown-previewer";
        rev = "a16b6d04629649ab2841335f6b56beaaa4e7a0d8";
        sha256 = "sha256-mSmhtW7gltvOL8xp2j01FuEIH4hHERe1UfRoIDc9PXU=";
      };
      npmDepsHash = "sha256-WQPJcflgMr6rsT/G+1LQFoC952cf0Qi4HzQdTKb19vg=";
      dontNpmBuild = true;

      installPhase = ''
        npm install

        mkdir $out
        cp -r * $out/
      '';
    };

    nativeBuildInputs = [ pkgs.emacs29 ];

    # the other files don't compile
    buildPhase = ''
      mkdir -p app/browser
      cp -r $browserJS/* app/browser

      mkdir -p app/pdf-viewer
      cp -r $pdfviewer app/pdf-viewer/

      mkdir -p app/org-previewer
      cp -r $orgpreviewJS/* app/org-previewer/

      mkdir -p app/markdown-previewer
      cp -r $markdownpreviewJS/* app/markdown-previewer/

      cd core
      emacs -L . --batch -f batch-byte-compile *.el
      cd ..
    '';

    installPhase = ''
      LISPDIR=$out/share/emacs/site-lisp

      install -d $LISPDIR
      cp -r * $LISPDIR
    '';
  };

  env = {
    "QT_QPA_PLATFORM_PLUGIN_PATH" = "${pkgs.qt6.qtbase.outPath}/lib/qt-6/plugins";
  };

  binaryPackages = with pkgs; [
    pyDeps
    wmctrl
    xdotool
    aria
  ];
}

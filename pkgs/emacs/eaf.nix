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
    p.epc p.lxml # for eaf
    #p.qrcode # eaf-file-browser
    p.pysocks # eaf-browser
    p.pymupdf # eaf-pdf-viewer
    #p.pypinyin # eaf-file-manager
    #p.psutil # eaf-system-monitor
    p.retry # eaf-markdown-previewer
    p.markdown
  ]);

in
{

  elisp = pkgs.stdenvNoCC.mkDerivation {
    name = "eaf-0.0.0";

    src = pkgs.fetchFromGitHub {
      owner = "emacs-eaf";
      repo = "emacs-application-framework";
      rev = "46733de03bcd9f20c54747753aa4fd2669f7b4ce";
      sha256 = "sha256-5/oV93RmytyxRKMHVzpcdb6XusoO1KRFlscPKaNsgIo=";
    };

    browserJS = pkgs.buildNpmPackage rec {
      pname = "eaf-browser";
      version = "0.0.1";
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

    nativeBuildInputs = [ pkgs.emacs29 pkgs.nodejs ];

    # the other files don't compile
    buildPhase = ''
      mkdir -p app/browser
      cp -r $browserJS/* app/browser

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
    pyDeps wmctrl xdotool aria
  ];
}

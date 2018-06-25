pkgs:
let
  nixos1709 = (import <nixos1709> {}).pkgs;
  nixos1803 = (import <nixos1803> {}).pkgs;
  callPackage = pkgs.lib.callPackageWith(custom // pkgs);
  custom = {
    blueimpGallery = callPackage ./blueimp-gallery {};
    blueimpImageGallery = callPackage ./blueimp-image-gallery {};
    c544ppd = callPackage ./lexmark-c544 {};
    cask = callPackage ./cask {};
    cdparanoiax = callPackage ./cdparanoiax {};
    clojuredocs = callPackage ./clojure-docs {};
    conkeror = nixos1803.conkeror;
    coursier = callPackage ./coursier {};
    derby = callPackage ./derby {};
    drip = callPackage ./drip {};
    ejabberd15 = callPackage ./ejabberd {};
#    elexis = callPackage ./elexis {};
    # elmPackages = pkgs.elmPackages // {
    #   elm-oracle = callPackage ./elm-oracle {};
    #   elm-test = callPackage ./elm-test {};
    # };
    exim = callPackage ./exim {};
    fileshelter = callPackage ./fileshelter {};
    freerdpUnstable = callPackage ./freerdp {};
    gitblit = callPackage ./gitblit {};
    gitbucket = callPackage ./gitbucket {};
    handlebars = callPackage ./handlebars {};
    hinclient = callPackage ./hinclient {};
    hl5380ppd = callPackage ./brother-hl5380 {};
    html2textpy = callPackage ./html2textpy {};
    javadocs = callPackage ./java-docs {};
    jquery2 = callPackage ./jquery2 {};
    kube = callPackage ./kube {};
    lsdvd = callPackage ./lsdvd {};
    makemkv = callPackage ./makemkv {};
    markdown = callPackage ./markdown {};
    mediathekview = callPackage ./mediathekview {};
    mongodex = callPackage ./dex {};
    mongodb-tools = callPackage ./mongodb-tools {};
    msgconvert = callPackage ./msgconvert {};
    neomodmap = callPackage ./neomodmap {};
    nginx =  callPackage ./nginx {};
    odt2org = callPackage ./odt2org {};
    orgHtmlThemes = callPackage ./org-html-themes {};
    pam_script = callPackage ./pam-script {};
    pill = callPackage ./pill {};
    publet = callPackage ./publet {};
    publetQuartz = callPackage ./publet/quartz.nix {};
    publetSharry = callPackage ./publet/sharry.nix {};
    recutils = callPackage ./recutils {};
    roundcube = callPackage ./roundcube {};
    scaladocs = callPackage ./scala-docs {};
    sharry = callPackage ./sharry {};
    shelter = callPackage ./shelter {};
    sig = callPackage ./sig {};
    sitebag = callPackage ./sitebag {};
    spark = callPackage ./spark {};
    storeBackup = callPackage ./storebackup {};
    stumpwmdocs = callPackage ./stumpwm/docs.nix {};
    tesseract304 = callPackage ./tesseract {};
    twitterBootstrap3 = callPackage ./twbs {};
    utaxccdclp = callPackage ./utaxccdclp {};
    visualvm = callPackage ./visualvm {};
    imagemagick695 = callPackage ./imagick{};
#    flashplayer = callPackage ./flashplayer {};
    stumpwm = nixos1709.stumpwm; #callPackage ./stumpwm {};
    lispPackages = {
      # the window-manager option adds this to systemPackages
      stumpwm = nixos1709.stumpwm;
    };
  };
  osxcollection = import ./osxcollection/default.nix (custom // pkgs);
in custom // { inherit osxcollection; }

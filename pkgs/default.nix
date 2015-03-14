pkgs:
let
  callPackage = pkgs.lib.callPackageWith(pkgs // custom);
  callPackage2 = pkgs.lib.callPackageWith(pkgs);
  custom = {
    blueimpGallery = callPackage ./blueimp-gallery {};
    blueimpImageGallery = callPackage ./blueimp-image-gallery {};
    cdparanoiax = callPackage ./cdparanoiax {};
    c544ppd = callPackage ./lexmark-c544 {};
    clojuredocs = callPackage ./clojure-docs {};
    exim = callPackage ./exim {};
    gitblit = callPackage ./gitblit {};
    handlebars = callPackage ./handlebars {};
    html2textpy = callPackage ./html2textpy {};
    javadocs = callPackage ./java-docs {};
    jquery2 = callPackage ./jquery2 {};
    kube = callPackage ./kube {};
    lsdvd = callPackage ./lsdvd {};
    markdown = callPackage ./markdown {};
    mediathekview = callPackage ./mediathekview {};
    nginx = callPackage ./nginx {};
    publet = callPackage ./publet {};
    publetSharry = callPackage ./publet/sharry.nix {};
    publetQuartz = callPackage ./publet/quartz.nix {};
    roundcube = callPackage ./roundcube {};
    scaladocs = callPackage ./scala-docs {};
    shelter = callPackage ./shelter {};
    sig = callPackage ./sig {};
    sitebag = callPackage ./sitebag {};
    soundkonverter = callPackage ./soundkonverter {};
    stumpwm = callPackage2 ./stumpwm {};
    stumpwmdocs = callPackage ./stumpwm/docs.nix {};
    twitterBootstrap3 = callPackage ./twbs {};
  };

in custom

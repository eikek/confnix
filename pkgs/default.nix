pkgs:
let
  callPackage = pkgs.lib.callPackageWith(custom // pkgs);
  custom = {
    c544ppd = callPackage ./lexmark-c544 {};
    cdparanoiax = callPackage ./cdparanoiax {};
    clojuredocs = callPackage ./clojure-docs {};
    conkeror = callPackage ./conkeror {};
    exim = callPackage ./exim {};
    gitblit = callPackage ./gitblit {};
    html2textpy = callPackage ./html2textpy {};
    javadocs = callPackage ./java-docs {};
    jquery2 = callPackage ./jquery2 {};
    kube = callPackage ./kube {};
    lsdvd = callPackage ./lsdvd {};
    markdown = callPackage ./markdown {};
    mediathekview = callPackage ./mediathekview {};
    nginx = callPackage ./nginx {};
    roundcube = callPackage ./roundcube {};
    publet = callPackage ./publet {};
    publetSharry = callPackage ./publet/sharry.nix {};
    publetQuartz = callPackage ./publet/quartz.nix {};
    shelter = callPackage ./shelter {};
    scaladocs = callPackage ./scala-docs {};
    sitebag = callPackage ./sitebag {};
    soundkonverter = callPackage ./soundkonverter {};
    stumpwm = callPackage ./stumpwm {};
    stumpwmdocs = callPackage ./stumpwm/docs.nix {};
  };

in custom

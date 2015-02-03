pkgs:
let
  callPackage = pkgs.lib.callPackageWith(pkgs // custom);
  callPackage2 = pkgs.lib.callPackageWith(pkgs);
  custom = {
    cdparanoiax = callPackage ./cdparanoiax {};
    c544ppd = callPackage ./lexmark-c544 {};
    clojuredocs = callPackage ./clojure-docs {};
    exim = callPackage ./exim {};
    gitblit = callPackage ./gitblit {};
    html2textpy = callPackage ./html2textpy {};
    javadocs = callPackage ./java-docs {};
    jquery2 = callPackage ./jquery2 {};
    kube = callPackage ./kube {};
    lsdvd = callPackage ./lsdvd {};
    markdown = callPackage ./markdown {};
    roundcube = callPackage ./roundcube {};
    publet = callPackage ./publet {};
    publetSharry = callPackage ./publet/sharry.nix {};
    publetQuartz = callPackage ./publet/quartz.nix {};
    shelter = callPackage ./shelter {};
    scaladocs = callPackage ./scala-docs {};
    sitebag = callPackage ./sitebag {};
    soundkonverter = callPackage ./soundkonverter {};
    stumpwm = callPackage2 ./stumpwm {};
    stumpwmdocs = callPackage ./stumpwm/docs.nix {};
  };

in custom

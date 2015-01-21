pkgs:
let
  callPackage = pkgs.lib.callPackageWith(pkgs // custom);
  callPackage2 = pkgs.lib.callPackageWith(pkgs);
  custom = {
    cdparanoiax = callPackage ./cdparanoiax {};
    exim = callPackage ./exim {};
    gitblit = callPackage ./gitblit {};
    html2textpy = callPackage ./html2textpy {};
    jquery2 = callPackage ./jquery2 {};
    kube = callPackage ./kube {};
    lsdvd = callPackage ./lsdvd {};
    roundcube = callPackage ./roundcube {};
    publet = callPackage ./publet {};
    shelter = callPackage ./shelter {};
    sitebag = callPackage ./sitebag {};
    soundkonverter = callPackage ./soundkonverter {};
    stumpwm = callPackage2 ./stumpwm {};
  };

in custom

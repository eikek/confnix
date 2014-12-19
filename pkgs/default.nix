pkgs:
let
  callPackage = pkgs.lib.callPackageWith(pkgs // custom);

  custom = {
    exim = callPackage ./exim {};
    gitblit = callPackage ./gitblit {};
    html2textpy = callPackage ./html2textpy {};
    jquery2 = callPackage ./jquery2 {};
    kube = callPackage ./kube {};
    roundcube = callPackage ./roundcube {};
    publet = callPackage ./publet {};
    shelter = callPackage ./shelter {};
    sitebag = callPackage ./sitebag {};
  };

in custom

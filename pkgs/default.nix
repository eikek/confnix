pkgs:
let
  callPackage = pkgs.lib.callPackageWith(pkgs // custom);

  custom = {
    exim = callPackage ./exim {};
    gitblit = callPackage ./gitblit {};
    html2textpy = callPackage ./html2textpy {};
    roundcube = callPackage ./roundcube {};
    shelter = callPackage ./shelter {};
    sitebag = callPackage ./sitebag {};
    sqliteman = callPackage ./sqliteman {};
  };

in custom

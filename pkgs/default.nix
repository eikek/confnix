pkgs:
let
  callPackage = pkgs.lib.callPackageWith (custom // pkgs);
  sbts = pkgs.callPackage ./sbt { };
  custom = {
    attentive = callPackage ./attentive { };
    chee = callPackage ./chee { };
    keymapp = callPackage ./keymapp { };
    mc2425ppd = callPackage ./mc2425ppd { };
    mc3ppd = callPackage ./mc3ppd { };
    meth = callPackage ./meth { };
    mpc4s = callPackage ./mpc4s { };
    msgconvert = callPackage ./msgconvert { };
    myemacs = callPackage ./emacs { };
    pickup = callPackage ./pickup { };
    solr = callPackage ./solr { };
    sig = callPackage ./sig { };
    tmm = callPackage ./tmm { };

    sbt8 = sbts.sbt8;
    sbt11 = sbts.sbt11;
    sbt17 = sbts.sbt17;
  };
in
custom

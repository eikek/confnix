pkgs:
let
  ifds = import ../ifd;
  callPackage = pkgs.lib.callPackageWith(custom // pkgs);
  sbts = callPackage ./sbt {};
  custom = {
    attentive = callPackage ./attentive {};
    c544ppd = callPackage ./c544ppd {};
    chee = callPackage ./chee {};
    docspell = callPackage ifds.docspell.currentPkg {};
    gossa = callPackage ./gossa {};
    hinclient = callPackage ./hinclient {};
    meth = callPackage ./meth {};
    mpc4s = callPackage ./mpc4s {};
    msgconvert = callPackage ./msgconvert {};
    pickup = callPackage ./pickup {};
    sharry = callPackage ./sharry {};
    tmm = callPackage ./tmm {};
    webact = callPackage ./webact {};

    # Overriding
    sbt = sbts.sbt;
    sbt11 = sbts.sbt11;
  };
in custom

pkgs:
let
  ifds = import ../ifd;
  callPackage = pkgs.lib.callPackageWith(custom // pkgs);
  sbts = callPackage ./sbt {};
  p = import ../nixversions.nix {};
  custom = p // {
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
    sharry = callPackage ifds.sharry.currentPkg {};
    sig = callPackage ./sig {};
    tmm = callPackage ./tmm {};
    webact = callPackage ifds.webact.currentPkg {};

    # Overriding
    sbt = sbts.sbt;
    sbt11 = sbts.sbt11;
  };
in custom

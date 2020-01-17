pkgs:
let
  callPackage = pkgs.lib.callPackageWith(custom // pkgs);
  sbts = callPackage ./sbt {};
  custom = {
    attentive = callPackage ./attentive {};
    c544ppd = callPackage ./c544ppd {};
    chee = callPackage ./chee {};
    docspell = callPackage ./docspell {};
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

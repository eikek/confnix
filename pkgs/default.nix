pkgs:
let
  callPackage = pkgs.lib.callPackageWith(custom // pkgs);
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
  };
in custom

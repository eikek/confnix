pkgs:
let
  callPackage = pkgs.lib.callPackageWith(custom // pkgs);
  custom = {
    attentive = callPackage ./attentive {};
    c544ppd = callPackage ./c544ppd {};
    chee = callPackage ./chee {};
    gossa = callPackage ./gossa {};
    meth = callPackage ./meth {};
    mpc4s = callPackage ./mpc4s {};
    pickup = callPackage ./pickup {};
    sharry = callPackage ./sharry {};
    webact = callPackage ./webact {};
  };
in custom

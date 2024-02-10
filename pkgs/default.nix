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
    ds4e = callPackage ifds.ds4e {};
    gossa = callPackage ./gossa {};
    mc2425ppd = callPackage ./mc2425ppd {};
    meth = callPackage ./meth {};
    mpc4s = callPackage ./mpc4s {};
    msgconvert = callPackage ./msgconvert {};
    myemacs = callPackage ./emacs {};
    pickup = callPackage ./pickup {};
    sharry = callPackage ifds.sharry.currentPkg {};
    solr = callPackage ./solr {};
    sig = callPackage ./sig {};
    tmm = callPackage ./tmm {};
    webact = callPackage ifds.webact.currentPkg {};

    # Overriding
    mpd = p.pkgs1909.mpd; # must upgrade mpc4s :(
    sbt8 = sbts.sbt8;
    sbt11 = sbts.sbt11;
    jetbrains.idea-community = p.pkgsUnstable.jetbrains.idea-community;
  };
in custom

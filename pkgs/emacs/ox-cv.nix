{ pkgs, emacsPackages }:

pkgs.emacs.trivialBuild rec {

  pname = "ox-cv";

  version = "0.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "mylese";
    repo = "${pname}";
    rev = "d11c65e7b29fe3489d49fdf91b808eace314f879";
    sha256 = "0cgagyllwbqax9y52y5qiz64daqz0dwcvmpl1a5phjvkvjrfd8d0";
  };

  packageRequires = with emacsPackages; [ ];
}

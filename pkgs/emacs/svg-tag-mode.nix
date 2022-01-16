{ pkgs, emacsPackagesNg }:

emacsPackagesNg.trivialBuild rec {

  pname = "svg-tag-mode";

  version = "0.3.2";

  src = pkgs.fetchFromGitHub {
    owner = "rougier";
    repo = "${pname}";
    rev = "3b07983614bee0195534e7a8a6dcfab757da4f0b";
    sha256 = "0nc0y2dn67gy9cly3yamskfd9dd028xbask8gjxql934bq0ads2i";
  };

  packageRequires = with emacsPackagesNg; [ svg-lib ];
}

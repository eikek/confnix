{ pkgs, emacsPackages }:

emacsPackages.trivialBuild rec {

  pname = "scala-ts-mode";

  version = "0.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "KaranAhlawat";
    repo = "${pname}";
    rev = "889a90557c4d35b2ac5dde3dcb59f7e5ac1b03bc";
    sha256 = "sha256-Wd70GYYYYASKa3RlFQI3JlwXzasFr5ZgSZZaaEsxj5Y";
  };

  packageRequires = with emacsPackages; [  ];
}

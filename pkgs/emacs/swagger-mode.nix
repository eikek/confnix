{ pkgs, emacsPackages }:

emacsPackages.trivialBuild rec {

  pname = "swagger-mode";

  version = "0.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "Nooby";
    repo = "${pname}";
    rev = "fc6cb0a4c3aec4e7653f0028d76bd864b3569630";
    sha256 = "0cljc0yrhg8mw3alfmzigjl96q847pr69qii0dxraiqf5gjyjy53";
  };

  packageRequires = with emacsPackages; [ ];
}

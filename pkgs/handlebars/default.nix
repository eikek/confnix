{stdenv, fetchgit}:

stdenv.mkDerivation rec {
  version = "3.0.0";
  name = "hanlebars-${version}";

  src = fetchgit {
    url = "https://github.com/components/handlebars.js";
    rev = "refs/tags/v${version}";
    name = "handlebars-${version}-git";
    sha256 = "0wlf1claqhzbpvv615vj4rmib0s6m19j693q68f7iadjnxvmg9d0";
  };

  installPhase = ''
    mkdir -p $out
    mv * $out
  ''; #*/

  meta = with stdenv.lib; {
    description = "Handlebars";
    homepage = https://github.com/wycats/handlebars.js/;
    license = licenses.mit;
    maintainers = [ maintainers.eikek ];
  };
}

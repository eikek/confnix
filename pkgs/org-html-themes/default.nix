{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {

  version = "20180411";

  name = "org-html-themes-${version}";

  src = fetchFromGitHub {
    owner = "fniessen";
    repo = "org-html-themes";
    rev = "2cacdec6be7a734630e553fd1c9c93665f74e667";
    sha256 = "1fb44gmh17waajr5za40fwz2ypbgd6rfmx4qyb69w0wkvj29cz9h";
  };

  buildPhase = "";

  installPhase = ''
    mkdir -p $out/share/org-html-themes
    cp -R . $out/share/org-html-themes/
  '';
}

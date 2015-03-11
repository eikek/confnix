{stdenv, fetchgit}:

stdenv.mkDerivation rec {
  version = "3.200.3";
  name = "html2textpy-${version}";

  src = fetchgit {
    url = https://github.com/aaronsw/html2text;
    rev = "refs/heads/master";
    name = "html2textpy-${version}-git";
    sha256 = "0wwm5l6kj580ci9gjvcx0npaxw4hj8yvzrps2r59bzz7hrfmjzc1";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp html2text.py $out/bin/html2text_py
    chmod 755 $out/bin/html2text_py
  '';

  meta = with stdenv.lib; {
    description = "html2text is a Python script that converts a page of HTML into clean, easy-to-read plain ASCII text.";
    homepage = https://github.com/aaronsw/html2text;
    license = licenses.gpl3;
    maintainers = [ maintainers.eikek ];
  };
}

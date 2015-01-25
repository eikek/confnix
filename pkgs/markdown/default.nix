{stdenv, perl, fetchurl, unzip}:

stdenv.mkDerivation rec {

  name = "markdown-1.0.1";

  src = fetchurl {
    url = http://daringfireball.net/projects/downloads/Markdown_1.0.1.zip;
    sha256 = "0dq1pj91pvlwkv0jwcgdfpv6gvnxzrk3s8mnh7imamcclnvfj835";
  };

  buildInputs = [unzip];

  unpackPhase = "unzip $src && cd Markdown_1.0.1";

  patchPhase = ''
    sed -i 's,/usr/bin/perl,${perl}/bin/perl,g' Markdown.pl
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp Markdown.pl $out/bin/markdown
  '';

  meta = with stdenv.lib; {
    description = "Markdown is a text-to-HTML conversion tool for web writers.";
    homepage = http://daringfireball.net/projects/markdown/;
    license = licenses.bsd3;
    maintainers = [ maintainers.eikek ];
  };
}

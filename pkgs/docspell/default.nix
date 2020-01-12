{stdenv, fetchzip, file, curl, inotifyTools, fetchurl, jre8_headless, unzip, bash}:
let
  version = "0.2.0";
  meta = with stdenv.lib; {
    description = "Docspell helps to organize and archive your paper documents.";
    homepage = https://github.com/eikek/docspell;
    license = licenses.gpl3;
    maintainers = [ maintainers.eikek ];
  };
in
{ server = stdenv.mkDerivation rec {
    name = "docspell-server-${version}";

     src = fetchurl {
       url = "https://github.com/eikek/docspell/releases/download/v${version}/docspell-restserver-${version}.zip";
       sha256 = "1q6128wqbm9nvlp34wf1fgv4hwjjvn2nzqr954sdswqs926d0jvh";
     };

    buildInputs = [ jre8_headless ];

    unpackPhase = ''
      ${unzip}/bin/unzip $src
    '';

    buildPhase = "true";

    installPhase = ''
      mkdir -p $out/{bin,program}
      cp -R docspell-*/* $out/program/
      cat > $out/bin/docspell-restserver <<-EOF
      #!${bash}/bin/bash
      $out/program/bin/docspell-restserver -java-home ${jre8_headless} "\$@"
      EOF
      chmod 755 $out/bin/docspell-restserver
    '';

    inherit meta;
  };

  joex = stdenv.mkDerivation rec {
    name = "docspell-joex-${version}";

     src = fetchurl {
       url = "https://github.com/eikek/docspell/releases/download/v${version}/docspell-joex-${version}.zip";
       sha256 = "0ar2347zf3a2w3x52bcawpvi348zabplrfyb9k7i7ssv7ggji546";
     };

    buildInputs = [ jre8_headless ];

    unpackPhase = ''
      ${unzip}/bin/unzip $src
    '';

    buildPhase = "true";

    installPhase = ''
      mkdir -p $out/{bin,program}
      cp -R docspell-*/* $out/program/
      cat > $out/bin/docspell-joex <<-EOF
      #!${bash}/bin/bash
      $out/program/bin/docspell-joex -java-home ${jre8_headless} "\$@"
      EOF
      chmod 755 $out/bin/docspell-joex
    '';

    inherit meta;
  };

  tools = stdenv.mkDerivation rec {
    name = "docspell-tools-${version}";

    src = fetchzip {
      url = "https://github.com/eikek/docspell/archive/v${version}.zip";
      sha256 = "0kam7hyn9624w8br4nd64p6r9vh9jq3mpk95h75iz32h4i32l20f";
      name = "docspell-source";
    };

    buildPhase = "true";

    installPhase = ''
      mkdir -p $out/bin
      cp $src/tools/consumedir.sh $out/bin/
      cp $src/tools/ds.sh $out/bin/ds
      sed -i 's,CURL_CMD="curl",CURL_CMD="${curl}/bin/curl",g' $out/bin/consumedir.sh
      sed -i 's,CURL_CMD="curl",CURL_CMD="${curl}/bin/curl",g' $out/bin/ds
      sed -i 's,INOTIFY_CMD="inotifywait",INOTIFY_CMD="${inotifyTools}/bin/inotifywait",g' $out/bin/consumedir.sh
      sed -i 's,FILE_CMD="file",FILE_CMD="${file}/bin/file",g' $out/bin/ds
    '';

    inherit meta;
  };

}

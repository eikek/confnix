{stdenv, fetchzip, file, curl, inotifyTools, fetchurl, jre8_headless, unzip, bash}:
let
  version = "0.1.0";
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
       sha256 = "16acil5yrsi5lkldzx52wpg6p7fjzq3xnpyqrcmwml0rf0qrf1jd";
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
       sha256 = "02rpi35hdj333pjh56ik3r8cx5nawlkijbidrjl6ksbs065ynnfj";
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
    name = "docspell-tool-${version}";

    src = fetchzip {
      url = "https://github.com/eikek/docspell/archive/master.zip";
      sha256 = "06mjf5dl3cqqaaxhb4vj0195i0j8p5gkrwzw0pj2snlq7z4s3lk6";
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

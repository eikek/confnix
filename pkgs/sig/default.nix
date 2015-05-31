{ stdenv, fetchgit, jquery2, blueimpGallery, blueimpImageGallery, twitterBootstrap3, imagemagick, jhead, guile, curl, ffmpeg }:

stdenv.mkDerivation rec {
  version = "0.1.0a-20150531";
  name = "simple-image-gallery-${version}";

  src = fetchgit {
    url = https://github.com/eikek/sig;
    rev = "1857bdff5386a30769b7baedd994144893786b5e";
    name = "sig-git-${version}";
    sha256 = "14z5r54vq07fd4b89w1k849aqglj57rzi2ka1rbb5zjcrjhwg6m1";
  };

  patchPhase = ''
    sed -i 's|/usr/bin/guile|${guile}/bin/guile|g' sig.scm
    sed -i 's|http://code.jquery.com/jquery-2.1.3.min.js|${jquery2}/js/jquery.min.js|g' sig.scm
    sed -i 's|https://blueimp.github.io/Gallery/js/jquery.blueimp-gallery.min.js|${blueimpGallery}/js/jquery.blueimp-gallery.min.js|g' sig.scm
    sed -i 's|https://raw.githubusercontent.com/blueimp/Bootstrap-Image-Gallery/master/js/bootstrap-image-gallery.min.js|${blueimpImageGallery}/js/bootstrap-image-gallery.min.js|g' sig.scm
    sed -i 's|http://netdna.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css|${twitterBootstrap3}/dist/css/bootstrap.min.css|g' sig.scm
    sed -i 's|http://netdna.bootstrapcdn.com/bootstrap/3.3.4/fonts/glyphicons-halflings-regular.eot|${twitterBootstrap3}/dist/fonts/glyphicons-halflings-regular.eot|g' sig.scm
    sed -i 's|http://netdna.bootstrapcdn.com/bootstrap/3.3.4/fonts/glyphicons-halflings-regular.svg|${twitterBootstrap3}/dist/fonts/glyphicons-halflings-regular.svg|g' sig.scm
    sed -i 's|http://netdna.bootstrapcdn.com/bootstrap/3.3.4/fonts/glyphicons-halflings-regular.ttf|${twitterBootstrap3}/dist/fonts/glyphicons-halflings-regular.ttf|g' sig.scm
    sed -i 's|http://netdna.bootstrapcdn.com/bootstrap/3.3.4/fonts/glyphicons-halflings-regular.woff|${twitterBootstrap3}/dist/fonts/glyphicons-halflings-regular.woff|g' sig.scm
    sed -i 's|http://netdna.bootstrapcdn.com/bootstrap/3.3.4/fonts/glyphicons-halflings-regular.woff2|${twitterBootstrap3}/dist/fonts/glyphicons-halflings-regular.woff2|g' sig.scm
    sed -i 's|https://raw.githubusercontent.com/blueimp/Gallery/master/css/blueimp-gallery.min.css|${blueimpGallery}/css/blueimp-gallery.min.css|g' sig.scm
    sed -i 's|https://raw.githubusercontent.com/blueimp/Bootstrap-Image-Gallery/master/css/bootstrap-image-gallery.min.css|${blueimpImageGallery}/css/bootstrap-image-gallery.min.css|g' sig.scm
    sed -i 's|https://raw.githubusercontent.com/blueimp/Gallery/master/img/error.png|${blueimpGallery}/img/error.png|g' sig.scm
    sed -i 's|https://raw.githubusercontent.com/blueimp/Gallery/master/img/error.svg|${blueimpGallery}/img/error.svg|g' sig.scm
    sed -i 's|https://raw.githubusercontent.com/blueimp/Gallery/master/img/play-pause.png|${blueimpGallery}/img/play-pause.png|g' sig.scm
    sed -i 's|https://raw.githubusercontent.com/blueimp/Gallery/master/img/play-pause.svg|${blueimpGallery}/img/play-pause.svg|g' sig.scm
    sed -i 's|https://raw.githubusercontent.com/blueimp/Gallery/master/img/video-play.png|${blueimpGallery}/img/video-play.png|g' sig.scm
    sed -i 's|https://raw.githubusercontent.com/blueimp/Gallery/master/img/video-play.svg|${blueimpGallery}/img/video-play.svg|g' sig.scm
    sed -i 's|https://raw.githubusercontent.com/blueimp/Gallery/master/img/loading.gif|${blueimpGallery}/img/loading.gif|g' sig.scm

    sed -i 's|\*sig/curl\* "curl"|*sig/curl* "${curl}/bin/curl"|g' sig.scm
    sed -i 's|\*sig/convert\* "convert"|*sig/convert* "${imagemagick}/bin/convert"|g' sig.scm
    sed -i 's|\*sig/composite\* "composite"|*sig/composite* "${imagemagick}/bin/composite"|g' sig.scm
    sed -i 's|\*sig/jhead\* "jhead"|*sig/jhead* "${jhead}/bin/jhead"|g' sig.scm
    sed -i 's|\*sig/ffmpeg\* "ffmpeg"|*sig/ffmpeg* "${ffmpeg}/bin/ffmpeg"|g' sig.scm
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv sig.scm $out/bin
    ln -snf $out/bin/sig.scm $out/bin/sig
    mv README.org $out
  '';
}

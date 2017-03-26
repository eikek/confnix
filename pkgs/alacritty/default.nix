# see https://gist.github.com/gilligan/63d4d4832fae996f3225cb59345c689e
{ stdenv,  cmake,  freetype,  fontconfig,  xclip
, pkgconfig, fetchFromGitHub, gperf, xorg, rustPlatform
}:

with rustPlatform;
with xorg;

buildRustPackage rec {
  name = "alacritty-${version}";
  version = "git-715d4f8b";

  src = fetchFromGitHub {
    owner = "jwilm";
    repo = "alacritty";
    rev = "715d4f8be8b80604a0b6a8464e55a60660f810a0";
    sha256 = "1asqqaz4n6flax0sw90ry1f9gp0kfs7bzpjpa652a8ja5xpl82a8";
  };

  depsSha256 = "1vag8dxz67qvrp5x5xccy88aibxy2ih1bz14bmjgi9zwrv17gz6v";

  buildInputs = [ cmake xclip freetype fontconfig ];

  nativeBuildInputs = [
    pkgconfig
    libX11
    libXcursor
    libXxf86vm
    libXi
    fontconfig
  ];

  meta = {
    description = "A cross-platform, GPU-accelerated terminal emulator";
    homepage = https://github.com/jwilm/alacritty/;
    license = with licenses; [ asl2 ];
  };
}

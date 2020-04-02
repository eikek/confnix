config:
let
  nixpkgs1803 = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs-channels/archive/nixos-18.03.tar.gz";
    sha256 = "0d9pkbax0phh392j6pzkn365wbsgd0h1cmm58rwq8zf9lb0pgkg2";
  };
  pkgs1803 = import nixpkgs1803 { config = config; };
  nixpkgs1809 = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs-channels/archive/nixos-18.09.tar.gz";
    sha256 = "16j95q58kkc69lfgpjkj76gw5sx8rcxwi3civm0mlfaxxyw9gzp6";
  };
  pkgs1809 = import nixpkgs1809 { config = config; };
  nixpkgs1903 = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs-channels/archive/nixos-19.03.tar.gz";
    sha256 = "11z6ajj108fy2q5g8y4higlcaqncrbjm3dnv17pvif6avagw4mcb";
  };
  pkgs1903 = import nixpkgs1903 { config = config; };
  nixpkgs1909 = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs-channels/archive/nixos-19.09.tar.gz";
    sha256 = "01dsh9932x6xcba2p0xg4n563b85i3p7s2sakj7yf2ws8pgmwhq9";
  };
  pkgs1909 = import nixpkgs1909 { config = config; };
in
{
  inherit pkgs1803 pkgs1809 pkgs1903 pkgs1909;

}

{ lib, pkgs, ... }:
let
  macOsFirmware =
    (pkgs.stdenvNoCC.mkDerivation {
      name = "brcm-firmware";

      # new files:
      #  nix-prefetch-url --type sha256 file:///place/of/file
      # copy the sha here (filenames must match)
      src = pkgs.requireFile {
        name = "firmware.tar";
        url = "file:///etc/nixos/firmware.tar";
        sha256 = "10gnnqnyiizmzvyx0lbrdahx4x5m58xpgadpgdq6m40qy3ijzd4f";
      };
      buildCommand = ''
        dir="$out/lib/firmware"
        mkdir -p "$dir"
        tar xf $src
        cp -r brcm "$dir"
      '';
    });
in
{
  hardware.firmware = [
    macOsFirmware
  ];
}

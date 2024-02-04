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
        sha256 = "1byfksgrsiqswlpjr6qdlw7syhap794h3wk036w0rnpkilnb12jc";
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

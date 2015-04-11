{ fetchurl, lib, storeBackup }:

lib.overrideDerivation storeBackup (attrs: {
   name = "store-backup-3.5";
   src = fetchurl {
     url = http://download.savannah.gnu.org/releases/storebackup/storeBackup-3.5.tar.bz2;
     sha256 = "0y4gzssc93x6y93mjsxm5b5cdh68d7ffa43jf6np7s7c99xxxz78";
   };
})

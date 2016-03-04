{ fetchgit, lib, conkeror }:

lib.overrideDerivation conkeror (attrs: {
   name = "conkeror-1.0pre-20160205";

   src = fetchgit {
     url = git://repo.or.cz/conkeror.git;
     rev = "9f2b5488764939a931550eda486ee89b48ded38e";
     sha256 = "0qc4jg5pszq14z9zzph2w0q43pxdy3ls7rg7s920bk2q3m0zmgqk";
   };

})

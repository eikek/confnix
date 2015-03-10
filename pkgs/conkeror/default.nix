{ fetchgit, lib, conkeror }:

lib.overrideDerivation conkeror (attrs: {
   name = "conkeror-1.0pre-20150310";

   src = fetchgit {
     url = git://repo.or.cz/conkeror.git;
     rev = "876f60a6d92047123418866ec7f9f4f367e91248";
     sha256 = "1zmq90bgw72h0bi6yyqy2pr7glfwzf21dhw0lp23ikkndz9nqyr0";
   };

})

{ fetchgit, lib, stumpwm }:

lib.overrideDerivation stumpwm (attrs: {
   name = "stumpwm-0.9.9";
   src =  fetchgit {
     url = "https://github.com/stumpwm/stumpwm";
     rev = "refs/tags/0.9.9";
     sha256 = "05fkng2wlmhy3kb9zhrrv9zpa16g2p91p5y0wvmwkppy04cw04ps";
   };
})

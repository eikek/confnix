{ nginx, nginxModules }:

nginx.override {
  modules =  [
    nginxModules.rtmp
    nginxModules.dav
    nginxModules.moreheaders
    nginxModules.lua
  ];
}

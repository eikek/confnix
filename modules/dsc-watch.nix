user: {pkgs, config, ... }:
{

  age.secrets.dsc-watch-config = {
    file = ../secrets/dsc-watch-config.age;
    owner = user;
  };

  age.secrets.dsc-watch-int = {
    file = ../secrets/dsc-watch-int.age;
    owner = user;
  };

  services.dsc-watch = {
    enable = true;
    integration-endpoint = {
      enabled = true;
      header-file = config.age.secrets.dsc-watch-int.path;
    };
    verbose = false;
    delete-files = true;
    watchDirs = ["/home/docspell"];
    configFile = config.age.secrets.dsc-watch-config.path;
  };

  system.activationScripts = {
    "dsc-watch" = ''
      mkdir -p /home/docspell
      chown ${user} /home/docspell
    '';
  };
}

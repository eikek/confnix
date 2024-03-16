user: { config, pkgs, ...}:

{

  age.secrets.proxy = {
    file = ../secrets/proxy.age;
    owner = user;
  };

  users.users.${user} = {
    packages = [
      (pkgs.writeShellScriptBin "chromium-proxy" ''
        set -euo pipefail
        mkdir -p $HOME/.config/chromium-proxy
        proxy=$(cat ${config.age.secrets.proxy.path})
        ${pkgs.chromium}/bin/chromium --user-data-dir=$HOME/.config/chromium-proxy --proxy-server=$proxy
      '')
    ];
  };
}

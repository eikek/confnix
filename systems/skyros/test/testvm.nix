{
  network.description = "skyros test vm";

  skyrosvm =
    { config, pkgs, ... }:
    let mykey = if (builtins.tryEval <sshkey>).success then
     builtins.readFile <sshkey>
     else builtins.throw ''Please specify a file that contains the
       ssh public key to deploy to the vm in order to connect to it.
       Add it to the NIX_PATH variable with key "sshkey".
     '' ;
    in
    {
      imports = [
       ./testconf.nix
       ];

      settings.primaryIp = pkgs.lib.mkForce "192.168.56.101";
      deployment.targetEnv = "virtualbox";
      deployment.virtualbox.memorySize = 2500;
      deployment.virtualbox.headless = true;

      users.extraUsers.root = {
        openssh.authorizedKeys.keys = [ mykey ];
      };
    };
}

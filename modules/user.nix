let
  keyFile = builtins.toPath <sshpubkey>;
  username = "eike";
in
{pkgs, config, ...}:
{

  users.users.${username} = {
    name = username;
    isNormalUser = true;
    uid = 1000;
    createHome = true;
    home = "/home/${username}";
    shell = pkgs.fish;
    openssh.authorizedKeys.keyFiles = [ keyFile ];
    extraGroups = [ "wheel" "disk" "adm" "systemd-journal" "vboxusers" ];
  };
  users.users.root = {
    openssh.authorizedKeys.keyFiles = [ keyFile ];
  };

  security.pam.enableSSHAgentAuth = true;

}

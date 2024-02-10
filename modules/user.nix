let
  sshkeys = import ../secrets/ssh-keys.nix;
in
username: {pkgs, config, ...}:
{

  users.users.${username} = {
    name = username;
    isNormalUser = true;
    uid = 1000;
    createHome = true;
    home = "/home/${username}";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [ sshkeys.${username} ];
    extraGroups = [ "wheel" "disk" "adm" "systemd-journal" "vboxusers" "adbusers" "networkmanager" "camera" ];
  };

}

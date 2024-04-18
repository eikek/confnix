let
  sshkeys = import ../secrets/ssh-keys.nix;
in
{ username, uid ? 1000 }: { pkgs, config, ... }:
{

  users.users.${username} = {
    name = username;
    isNormalUser = true;
    uid = uid;
    createHome = true;
    home = "/home/${username}";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys =
      if sshkeys.${username} != null then [ sshkeys.${username} ] else [ ];
    extraGroups = [ "wheel" "disk" "adm" "systemd-journal" "vboxusers" "adbusers" "networkmanager" "camera" "keys" ];
  };

}

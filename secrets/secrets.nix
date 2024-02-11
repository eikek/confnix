let
  vms = {
    kalamos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICkpXIpCy92uN5YPj2dnBJ6S/7fahGQT231coVya14PK";
    poros = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMRKSE0djYyRnHhMfjzVxM/zHRT53Qq8SsIj1gmmLPG2";
  };
  machines = {
    kalamos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO+827p9t8sfeogQpE5uX/OY7h2/yuEmuTGvSQg2qjgp";
    poros = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMdBVWc3Y6DElS2urnfC5l0gwLX+dSheIQhkZI6Q3Jjk";
    limnos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJN+u9NtD+TQpK22raOl9dUtbQZH8xBPSXokCicMrXZf";
  };

  sshkeys = import ./ssh-keys.nix;

  systems = (builtins.attrValues machines) ++ (builtins.attrValues vms);
  users = [ sshkeys.eike sshkeys.eike-nopw ];
in
{
  "dsc-watch-config.age".publicKeys = users ++ systems;
  "dsc-watch-int.age".publicKeys = users ++ systems;

  "eike.age".publicKeys = systems ++ [ sshkeys.eike sshkeys.eike-nopw ];
}

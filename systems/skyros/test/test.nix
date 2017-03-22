import <nixpkgs/nixos/tests/make-test.nix> {

  # Either the configuration of a single machine:
  machine =
    { config, pkgs, ... }:
    let
      skyrostests = pkgs.stdenv.mkDerivation {
        name = "skyrostests";
        src = ./runtests.sh;
        unpackPhase = "true";
        installPhase = ''
          mkdir -p $out/bin
          cp $src $out/bin/skyrostests.sh
          chmod 755 $out/bin/skyrostests.sh
        '';
      };
    in
    {
      imports = [ ./testconf.nix ];

      environment.systemPackages = [
        skyrostests
      ];
    };


  testScript =
    ''
      $machine->start;
      $machine->waitForUnit("exim.service");
      $machine->waitForOpenPort(25);

      $machine->waitForUnit("dovecot2imap.service");
      $machine->waitForOpenPort(143);

      $machine->waitForUnit("sshd.service");
      $machine->waitForOpenPort(22);

      $machine->waitForUnit("nginx.service");

      $machine->waitForUnit("gitea.service");
      $machine->waitForUnit("sitebag.service");
      $machine->waitForUnit("ejabberd15.service");
      $machine->waitForUnit("shelter.service");
      $machine->succeed("ls /var/data/shelter/users.db");

      $machine->succeed("curl http://id.testvm.com");
      $machine->succeed("curl http://git.testvm.com");
      $machine->succeed("curl http://webmail.testvm.com");
      $machine->succeed("curl http://bag.testvm.com");

      $machine->succeed("skyrostests.sh");
    '';
}

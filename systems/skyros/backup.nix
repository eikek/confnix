{ config, pkgs, lib, ... }:
let
  sourceDir = "/var/data";
  backupDir = "/var/backups/storebackup";
  backupConfig = pkgs.writeText "storebackup-conf" ''
    # run `storeBackup.pl -g filename.conf' to create a template config file

    sourceDir=${sourceDir}
    backupDir=${backupDir}
    writeExcludeLog=yes
    cpIsGnu=yes
    linkSymlinks=yes
    exceptDirs=*/temp */logs */log
    followLinks=1
    # keep backups which are not older than the specified amount
    # of time. This is like a default value for all days in
    # --keepWeekday. Begins deleting at the end of the script
    # the time range has to be specified in format 'dhms', e.g.
    # 10d4h means 10 days and 4 hours
    # default = 30d;
    # An archive flag is not possible with this parameter (see below).
    ;keepAll=
  '';
  backupScript = pkgs.writeScript "do-backup.sh" ''
    #!${pkgs.bash}/bin/bash -e
    ${pkgs.storeBackup}/bin/storeBackup.pl --file ${backupConfig}
  '';
in
{
  # do a backup every monday and thursday at 4 am
  services.cron.systemCronJobs = [
    "0 4 * * 1,4 root ${backupScript}"
  ];

  system.activationScripts = {
    storebackupSetup = ''
       mkdir -p ${backupDir}
    '';
  };
}

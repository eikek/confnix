{ config, lib, pkgs, ... }:

with config;

let
  localcf = pkgs.writeText "sa-local.cf"  ''
    # set required score a bit higher
    required_score 5.5
    # don't use any dns blacklists
    skip_rbl_checks 1

    # include generated whitelist
    include whitelist_from.txt
  '';
  mkwhitelist = pkgs.writeScript "mk-whitelist.sh" ''
  #!/bin/sh -e
  # go through all Sent mailboxes and collect To addresses
  # copied from: http://wiki.apache.org/spamassassin/ManualWhitelist#Automatically_whitelisting_people_you.27ve_emailed
  SENTMAIL=
  for d in /var/data/users/*; do  #*/
     if [ -r "$d/Maildir/.Sent/cur" ]; then
       SENTMAIL="$SENTMAIL $d/Maildir/.Sent/cur/*"
     fi
  done
  echo "whitelist_from *@eknet.org"
  cat $SENTMAIL |
        grep -Ei '^(To|cc|bcc):' |
        grep -oEi '[a-z0-9_.=/-]+@([a-z0-9-]+\.)+[a-z]{2,}' |
        tr "A-Z" "a-z" |
        sort -u |
        xargs -n 100 echo "whitelist_from"
  '';
  learnfromusers = pkgs.writeScript "learn-ham-and-spam.sh" ''
  #!/bin/sh -e
  LEARNHAM=".LearnNotSpam"
  LEARNSPAM=".LearnSpam"

  learn() {
    user=$(expr match ''${2#/var/data/users/} '\([a-zA-Z0-9]*\)')
    echo "Learn ham for user $user…"
    ${pkgs.spamassassin}/bin/sa-learn -u $user --dbpath /var/lib/spamassassin/user-$user/bayes $1 $2
    chown -R spamd:spamd /var/lib/spamassassin/user-$user/
  }
  find /var/data/users -type d | grep "$LEARNHAM/cur" | while read f; do
    learn "--ham" $f
  done
  find /var/data/users -type d | grep "$LEARNSPAM/cur" | while read f; do
    learn "--spam" $f
  done
  '';
in
{

  services.spamassassin = {
    enable = true;
    #debug = true;
  };

  services.cron.systemCronJobs = [
    "0 3 * * Sun root ${mkwhitelist} > /etc/spamassassin/whitelist_from.txt"
    "0 3 * * Sun root ${learnfromusers}"
  ];

  system.activationScripts = if (services.spamassassin.enable) then {
    spamassassincfg = ''
      mkdir -p /etc/spamassassin
      mkdir -p /var/lib/spamassassin
      chown -R spamd:spamd /var/lib/spamassassin
      cp -n ${pkgs.spamassassin}/share/spamassassin/* /etc/spamassassin/
      #*/
      rm -f /etc/spamassassin/local.cf
      ln -s ${localcf} /etc/spamassassin/local.cf
    '';
  } else {}
;
}

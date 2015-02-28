{pkgs, lib, domain, ip, amName ? "ns.eknet.org", amEmail ? "root.eknet.org", nameserver ? [], cnames ? [], arecords ? [], mx ? [], serial ? "2008022500"}:
with lib;
let
   zone = ''
   $TTL 86400
   @     IN SOA ${amName}. ${amEmail}. (
         ${serial}; serial
         3600; refresh
         600; retry
         1209600; expire
         3600) ;min ttl
   ${concatMapStringsSep "\n" (s: "      IN NS " + s + ".") nameserver}
   ${concatMapStringsSep "\n" (s: "      IN MX " + s.priority + " " + s.domain) mx}
            IN A ${ip}
   ${concatMapStringsSep "\n" (cn: cn + " IN A " + ip) arecords}
   ${concatMapStringsSep "\n" (cn: cn + " IN CNAME " + domain +".") cnames}
   '';

   zoneFile = pkgs.writeText (domain+".zone") zone;

in zoneFile

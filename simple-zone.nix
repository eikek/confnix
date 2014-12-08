{pkgs, lib, domain, ip, amName ? "ns.eknet.org", amEmail ? "root.eknet.org", nameserver ? [], cnames ? [], arecords ? [], mx ? []}:
with lib;
let
   zone = ''
   $TTL 86400
   @     IN SOA ${amName}. ${amEmail}. (
         2014120200; serial
         10800; refresh
         3600; retry
         604800; expire
         86400)
   ${concatMapStringsSep "\n" (s: "      IN NS " + s + ".") nameserver}
   ${concatMapStringsSep "\n" (s: "      IN MX " + s.priority + " " + s.domain) mx}
   ${concatMapStringsSep "\n" (cn: cn + " IN CNAME " + domain +".") cnames}
         IN A ${ip}
   ${concatMapStringsSep "\n" (cn: cn + " IN A " + ip) arecords}
   '';

   zoneFile = pkgs.writeText (domain+".zone") zone;

in zoneFile

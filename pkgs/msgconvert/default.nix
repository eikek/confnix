{ perlPackages, fetchurl }:

perlPackages.buildPerlModule rec {
  version = "0.918";
  pname = "msgconvert";
  src = fetchurl {
    url = "https://github.com/mvz/email-outlook-message-perl/archive/dist-${version}.tar.gz";
    sha256 = "14szla163qb6xzm9kql74n0vn0zzgqhyiw8vdl0v6ja84wsxlj91";
  };

  buildInputs = with perlPackages; [ EmailMIME EmailMIMEContentType Encode GetoptLong PodUsage IOString IOAll EmailSender EmailSimple OLEStorageLight ];

  meta = {
    description = "Converts MS Outlook MSG files to EML";
  };
}

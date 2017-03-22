#!/usr/bin/bash -e

echo "running skyros test script"

# try successful login with shelter
curl -s -D /dev/stdout -o /dev/null --data-urlencode login=eike --data-urlencode password=test123  http://localhost:7910/api/verify/form


#curl -s -D /dev/stdout -o /dev/null --data-urlencode login=eike --data-urlencode password=test123  http://localhost:7910/api/verify/form |head -n1 |grep "200 OK"



exit 0

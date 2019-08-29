#!/usr/bin/env bash
#
# This script creates an account.nix file based on the `pass` password
# manager.
#
# The account.nix file is referenced from various files and provides a
# central place for passwords.
#
# Arguments are a list of password-files.
#
# It works with the following conventions:
#
# - The first line is the password.
# - Subsequent lines are checked for a "key:value" syntax and also
#   added to the set.
# - The second line is the username, if it does not match the
#   key-value pattern above.
# - keys and values in the created attribute set are strings
#
# Usage:
#
#     pass2accounts.sh internet/site1 other/pass > accounts.nix

accounts="$@"
passcmd="pass"


function fromLine() {
    declare -A attrs
    while read num line; do
        if [ "$num" == "1" ]; then
            attrs['password']="$line"
        elif [ "$num" == "2" ]; then
            if [[ "$line" == *":"* ]]; then
                attrs['username']=$(echo $line | cut -d':' -f2 | xargs)
            else
                attrs['username']="$line"
            fi
        else
            if [[ "$line" == *":"* ]]; then
                IFS=':' read -r key value <<< "$line"
                key=$(echo $key|xargs)
                value=$(echo $value|xargs)
                if [ "$key" == "username" ]; then
                    (>&2 echo "Not overwriting username with a value not in line 2")
                else
                    attrs[$key]=$value
                fi
            fi
        fi
    done
    for i in "${!attrs[@]}"
    do
        printf '    "%s" = "%s";\n' "$i" "${attrs[$i]}"
    done
}


function makeAttrs() {
    account="$1"
    $passcmd show $account | head -n9 | nl | fromLine
}

printf "{\n"
for acc in $accounts; do
    printf '  "%s" = {\n' $acc
    makeAttrs $acc
    printf "  };\n"
done
printf "}"

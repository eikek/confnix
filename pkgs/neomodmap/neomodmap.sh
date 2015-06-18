#!/bin/bash -e

case "$1" in
    on)
        setxkbmap lv && xmodmap neo_de.modmap && xset -r 51
        if [ $? -eq 0 ];
        then
            echo "Neo map loaded."
        else
            echo "Failed."
            $0 off
        fi
        ;;

    off)
        setxkbmap de && xset r 51
        if [ $? -eq 0 ];
        then
            echo "Loaded de map."
        else
            echo "Error loading de map."
        fi
        ;;

    status)
        setxkbmap -print
        ;;

    toggle)
        if setxkbmap -print |grep qwertz >/dev/null;
        then
            $0 on
        else
            $0 off
        fi
        ;;
    *)
        echo "Usage: $0 {on|off|status|toggle}"
        exit 1
esac

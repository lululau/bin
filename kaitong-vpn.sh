#!/bin/bash

status=$(scutil --nc status Kaitong | head -1)

if [ "$status" = Connected ]; then
    scutil --nc stop Kaitong
else
    scutil --nc start Kaitong
    cat <<EOF | osascript -ss
        delay 2
        tell app "System Events"
        keystroke "_kaitong.vpn.2015!_"
        keystroke return
        end
EOF
fi

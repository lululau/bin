#!/bin/bash

cat <<'EOF' | osascript -ss
set windowsInDock to {}
tell application "System Events" to set theNames to name of processes whose background only is false
repeat with n from 1 to count of theNames
    set appName to item n of theNames
    tell application "System Events" to tell process appName to try
        set window_idx to 0
        repeat with aWindow in (windows)
            tell aWindow to try
                set window_position to position of aWindow
                set window_size to size of aWindow
                set the_title to title of aWindow
                if the_title is missing value then
                    set the_title to ""
                end if
                set end of windowsInDock to {appName, the_title, window_position, window_size}
            on error errmess -- ignore errors
                
            end try
            set window_idx to window_idx + 1
        end repeat
    on error msg
        
    end try
end repeat
windowsInDock
EOF
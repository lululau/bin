#!/bin/bash

osascript <<EOF 
set processes to {$(ruby -e 'puts STDIN.map(&:chomp).map(&:inspect).*","' < ~/.windowmaxrc)}

tell application "Finder"
  set _b to bounds of window of desktop
  set w to item 3 of _b
  set h to item 4 of _b
end tell

repeat with proc in processes
  try
    tell application "System Events" to tell process proc
      repeat with wind in windows
        tell wind 
          set size to {w, h}
          set position to {0, 0}
        end tell
      end repeat
    end tell
  on error msg
  end try
end repeat
EOF

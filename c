#!/usr/bin/env zsh

if [ -n "$TMUX" ]; then
  capture_cmd='tmux capture-pane -pS -'
elif [ $(uname) = Darwin ]; then
  local contents=$(osascript -e "tell app \"iTerm\" to get contents of current session of current tab of current window")
  capture_cmd='echo "$contents"'
else
    capture_cmd='echo'
fi

tmpfile=$(mktemp)
basename=$(basename "$tmpfile")
eval "$capture_cmd" | perl -00 -pe 1 > "$tmpfile"
if [ "$(uname)" = Darwin ]; then
   emacsclient -t -s term -e "(progn (find-file \"$tmpfile\") (linum-mode) (end-of-buffer))"
   emacsclient -n -s term -e "(kill-buffer \"$basename\")"
else
   emacsclient -t -e "(progn (find-file \"$tmpfile\") (linum-mode) (end-of-buffer))"
   emacsclient -n -e "(kill-buffer \"$basename\")"
fi

rm "$tmpfile"

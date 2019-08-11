#!/bin/zsh

ALFRED_TMUX_DEFAULT_SESSION=cmd

iterm2_python=$HOME/Library/ApplicationSupport/iTerm2/iterm2env/versions/3.7.2/bin/python3

typeset -A ALFRED_TMUX_COMMAND_MAPPINGS=(
   "^hc$"        "Java:1.1; echo 'cd ~/kt/hc'"
   "^ddhc$"      "Java:1.2; echo 'cd ~/kt/ddhc'"
   "^hc2$"       "Java:2.1; echo 'cd ~/kt/hc2'"
   "^inf$"       "Java:2.2; echo 'cd ~/kt/infrastructure'"
   "^hcfe$"      "Java:3.1; echo"
   "^hcr$"       "Java:3.2; echo 'cd ~/kt/hcrawler'"
   "^ddmp$"      "Java:3.3; echo 'cd ~/kt/ddmp'"
   "^chelper$"   "Java:4.1; echo 'cd ~/cascode/rails-helper-apps/chelper'"
   "^bu.*$"      "cmd:1.1; echo 'brew upgrade && brew cleanup'"
   "^jk.*$"      "cmd:3.1; echo '#_'"
   "^repl$"      "repl:1; echo"
   "^cmd$"       "cmd:1.1; echo"
   "^tmp$"       "cmd:1.2; echo 'cd ~/tmp'"
   "^down.*$"    "cmd:1.2; echo 'cd ~/Downloads'"
   "^pry.*$"    "repl:1; echo"
   "^ptp.*$"    "repl:2; echo"
   "^jsh.*$"    "repl:3; echo"
   "^jay.*$"    "repl:4; echo"
)

function decorate_command() {
  local original_command=$(echo "$1" | perl -pe 'chomp;s/^\s*//;s/\s*$//')
  for key (${(k)ALFRED_TMUX_COMMAND_MAPPINGS}) {
      local value=$ALFRED_TMUX_COMMAND_MAPPINGS[$key]
      local target=${value%%;*}
      local session=${target%%:*}
      local window=${${target%%.*}#*:}
      local pane=${target##*.}
      local cmd=${value#*;}
      cmd=${cmd//\#_/"$original_command"}
      if [[ $original_command =~ "$key" ]]; then
        echo "$session"
        echo "$window"
        echo "$pane"
        eval "$cmd"
        return
      fi
  }
  echo "$ALFRED_TMUX_DEFAULT_SESSION"
  echo
  echo
  echo "$original_command"
}

function tmux_get_client_tty() {
  local session=$1
  tmux display-message -t "$session" -p "#{client_tty}"
}

function iterm2_show() {
  local session=$1
  local client_tty=$(tmux_get_client_tty "$session")
  $iterm2_python <<EOF
import iterm2;
async def main(conn):
  await iterm2.async_invoke_function(conn, "activate_session_by_tty(tty: \"$client_tty\")")
iterm2.run_until_complete(main)
EOF
}

function tmux_create_window() {
  local session=$1
  tmux new-window -t "$session" -P -F '#{window_index}'
}

function iterm2_tmux_exec() {
  local command=$1
  local session=$2
  local window=$3
  local pane=$4

  iterm2_show "$session"

  if [ -z "$window" ]; then
    window=$(tmux_create_window "$session")
  fi

  local target="$session:$window"
  if [ -z "$pane" ]; then
    pane=1
  fi
  target="$target.$pane"

  tmux select-window -t "$session:$window"
  tmux select-pane -t "$target"

  tmux send-keys -t "$target" "$command"
}

cd "$HOME"
local output=$(decorate_command "$1")
local session=$(echo "$output" | sed -n 1p)
local window=$(echo "$output" | sed -n 2p)
local pane=$(echo "$output" | sed -n 3p)
local command=$(echo "$output" | sed -n '4,$p')
if [ -n "$command" ]; then
  command=$command$'\n'
fi
iterm2_tmux_exec "$command" "$session" "$window" "$pane"


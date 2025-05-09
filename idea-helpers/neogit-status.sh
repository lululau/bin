#!/usr/bin/env zsh

if [ -z "$HOMEBREW_PREFIX" ]; then
  if [ -e "/opt/homebrew/bin/brew" ]; then
    HOMEBREW_PREFIX="/opt/homebrew"
  else
    HOMEBREW_PREFIX="/usr/local"
  fi
fi

##
# This script is used to open a file with an existing Neovide instance or a new
# one if none exists.

neovide_pid=$(ps -ef | grep Neovide | grep -v grep | awk '{print $2}')
if [ -z "$neovide_pid" ]; then
  open -a Neovide
  sleep 1
  neovide_pid=$(ps -ef | grep Neovide | grep -v grep | awk '{print $2}')
fi

if [ -z "$neovide_pid" ]; then
  echo "Neovide is not running, and could not be started."
  exit 1
fi
child_nvim_pid=$(ps -ef | grep $neovide_pid | grep -v 'grep\|Neovide' | awk '{print $2}')
if [ -z "$child_nvim_pid" ]; then
  echo "Neovide is running, but no child nvim process was found."
  exit 1
else
  child_nvim_pid=$(ps -ef | grep $child_nvim_pid | grep -v 'grep\|Neovide\|login' | awk '{print $2}')
  if [ -z "$child_nvim_pid" ]; then
    echo "Neovide is running, but no child nvim process was found."
    exit 1
  fi
fi

server_address=$(lsof -p $child_nvim_pid | grep "nvim.$child_nvim_pid" | awk '{print $NF}')
if [ -z "$server_address" ]; then
  echo "Neovide is running, but no server address was found."
  exit 1
fi

open -a Neovide

$HOMEBREW_PREFIX/bin/nvim --server "$server_address" --remote-send ":cd $PWD
:Neogit
"

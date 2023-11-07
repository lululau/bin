#!/bin/bash

##
# This script is used to open a file with an existing Neovide instance or a new
# one if none exists.

if [ -z "$1" ]; then
  echo "No file specified."
  exit 1
fi

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
fi

server_address=$(lsof -p $child_nvim_pid | grep "nvim.$child_nvim_pid" | awk '{print $NF}')
if [ -z "$server_address" ]; then
  echo "Neovide is running, but no server address was found."
  exit 1
fi

full_paths=()
for file in "$@"; do
  if [ ! -e "$file" ]; then
    mkdir -p "$(dirname "$file")"
    touch "$file"
  fi
  full_paths+=("$(realpath "$file")")
done

open -a Neovide
/usr/local/bin/nvim --server "$server_address" --remote "${full_paths[@]}"

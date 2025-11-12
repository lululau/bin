#!/bin/bash

if [ -z "$HOMEBREW_PREFIX" ]; then
  if [ -e "/opt/homebrew/bin/brew" ]; then
    HOMEBREW_PREFIX="/opt/homebrew"
  else
    HOMEBREW_PREFIX="/usr/local"
  fi
fi

# Function to resolve relative path to absolute path
resolve_path() {
  local path="$1"
  local working_dir="$2"

  # If already absolute path, return as is
  if echo "$path" | grep -q '^/'; then
    echo "$path"
    return
  fi

  # If relative path, resolve against working directory or current directory
  local target_dir="$working_dir"
  if [ -z "$target_dir" ]; then
    target_dir="$(pwd)"
  fi

  # Change to target directory and resolve path
  local original_pwd="$(pwd)"
  if cd "$target_dir" 2>/dev/null; then
    # If file exists, get absolute path
    if [ -f "$path" ]; then
      realpath "$path" 2>/dev/null || echo "$(pwd)/$path"
      cd "$original_pwd" 2>/dev/null
      return
    fi

    # If file doesn't exist, try to find it using find command (limited search)
    local found_file
    found_file=$(find . -name "$path" -type f 2>/dev/null | head -1)
    if [ -n "$found_file" ]; then
      realpath "$found_file" 2>/dev/null || echo "$(pwd)/$found_file"
      cd "$original_pwd" 2>/dev/null
      return
    fi
    cd "$original_pwd" 2>/dev/null
  fi

  # If not found, return original path (let open handle it)
  echo "$path"
}

# iTerm2 Semantic History may pass the working directory as a parameter
# Check if we have a second parameter that looks like a directory
working_dir=""
if [ -n "$1" ] && [ -d "$1" ]; then
  working_dir="$1"
fi

if echo "$2" | grep -q '^[$~/]'; then
  # Already absolute path or home path
  file="$2"
elif echo "$2" | grep -q "^[a-z]\+://"; then
  # URL
  file="$2"
elif echo "$2" | grep -q '^[a-zA-Z0-9_-]\+/[a-zA-Z0-9_-]\+$'; then
  # GitHub repository format: owner/repo
  open "https://github.com/$2"
  exit 0
elif echo "$2" | grep -q '^[a-zA-Z0-9_-]\+/[a-zA-Z0-9_-]\+ ([0-9.]\+%)$'; then
  # GitHub repository format with progress: owner/repo (percentage)
  repo=$(echo "$2" | sed 's/ \+([0-9.]\+%)//')
  open "https://github.com/$repo"
  exit 0
else
  # Relative path or filename - resolve it
  file=$(resolve_path "$2" "$working_dir")
fi

# Check if file is a Ruby file and we have a line number parameter
if echo "$file" | grep -q '\(\.rb$\)\|\(.rake$\)\|\(Gemfile\)' && [ -n "$3" ] && echo "$3" | grep -q '^[0-9]\+$'
then
    # Ruby file with line number - open in Emacs
    open -a Emacs
    $HOMEBREW_PREFIX/bin/emacsclient -n +"$3" "$file"
elif echo "$file" | grep -q '\(\.rb$\)\|\(.rake$\)\|\(Gemfile\)' && [ -n "$2" ] && echo "$2" | grep -q '^[0-9]\+$'
then
    # Ruby file with line number as second parameter
    open -a Emacs
    $HOMEBREW_PREFIX/bin/emacsclient -n +"$2" "$file"
elif [ -f "$file" ]; then
    # Regular file - open with default application
    open "$file"
else
    # File not found or doesn't exist, try to open anyway (might be a URL or other format)
    open "$file"
fi

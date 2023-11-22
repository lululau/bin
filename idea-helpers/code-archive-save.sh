#!/usr/bin/env zsh

if [ -z "$HOMEBREW_PREFIX" ]; then
  if [ -e "/opt/homebrew/bin/brew" ]; then
    HOMEBREW_PREFIX="/opt/homebrew"
  else
    HOMEBREW_PREFIX="/usr/local"
  fi
fi



script_dir=$(cd $(dirname $0); pwd)
source "$script_dir/project-root.sh"
row_col_no=$1
file_path=$2
project_root=$(cd "$(dirname "$file_path")"; project_root .)
project_root=${project_root/#\/\//\/}/
if echo "$file_path" | grep -qF 'src.zip!'; then
    file_path=/Users/liuxiang/cascode/java/java-sources$(echo "$file_path" | perl -pe 's#.*src\.zip!##')
fi

$HOMEBREW_PREFIX/bin/emacsclient -q --eval "(lx/switch-to-layout-of-project \"$project_root\")" &> /dev/null
$HOMEBREW_PREFIX/bin/emacsclient -n $row_col_no "$file_path"

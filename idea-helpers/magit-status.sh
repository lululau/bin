#!/usr/bin/env zsh

open -a Emacs

script_dir=$(cd $(dirname $0); pwd)
source "$script_dir/project-root.sh"
file_path=$2
project_root=$(cd "$(dirname "$file_path")"; project_root .)
project_root=${project_root/#\/\//\/}/

open -a Emacs.app
emacsclient -q --eval "(lx/switch-to-layout-of-project \"$project_root\")" &> /dev/null
emacsclient -q --eval "(magit-status)" &> /dev/null

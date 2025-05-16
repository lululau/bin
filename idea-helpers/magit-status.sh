#!/usr/bin/env zsh

open -a Emacs

project_root=$(git rev-parse --show-toplevel 2> /dev/null)

cd "$project_root"

open -a Emacs.app
emacsclient -q --eval "(lx/switch-to-layout-of-project \"$project_root\")" &> /dev/null
emacsclient -q --eval "(magit-status)" &> /dev/null

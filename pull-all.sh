#!/usr/bin/env zsh

REPOS=(
  ~/bin
  ~/.config
  ~/.emacs.d
  ~/.spacezsh
  ~/.oh-my-zsh
  ~/.tmux
  ~/.fzf
)

for repo in "${REPOS[@]}"; do
  echo "======== Start pulling $repo ========"
  (cd "$repo"; git pull)
  echo "======== Complete pulling $repo ========"
done

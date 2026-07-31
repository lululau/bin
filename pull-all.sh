#!/usr/bin/env zsh

REPOS=(
  ~/bin
  ~/.config
  ~/.emacs.spacemacs.d
  ~/.spacezsh
  ~/.oh-my-zsh
  ~/.tmux
  ~/.fzf
  ~/global-claude
  ~/icloud-repos/journal.git
  ~/icloud-repos/snippets.git
  ~/icloud-repos/webclips.git
  ~/icloud-repos/notes.git
  ~/icloud-repos/books.git
)

for repo in "${REPOS[@]}"; do
  echo "======== Start pulling $repo ========"
  (cd "$repo"; git pull)
  echo "======== Complete pulling $repo ========"
done

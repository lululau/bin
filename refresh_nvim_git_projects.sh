#!/bin/zsh

NVIM_PROJECT_FILE="$HOME/.local/share/nvim/project_nvim/project_history"

GIT_REPO_LOCATIONS=(
    "$HOME/kt"
    "$HOME/cascode"
)

function get_git_repo_paths() {
    for git_repo_location in "${GIT_REPO_LOCATIONS[@]}"; do
        find "$git_repo_location" -type d -name ".git" -maxdepth 3 -exec dirname {} \;
    done
}

for git_repo_path ($(get_git_repo_paths)); do
  if ! grep -q -F "$git_repo_path" "$NVIM_PROJECT_FILE" ; then
    echo $git_repo_path >> "$NVIM_PROJECT_FILE"
    echo "Added $git_repo_path to $NVIM_PROJECT_FILE"
  fi
done

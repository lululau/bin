#!/bin/bash

# An alias to the cursor cli

# env -u TMUX -u TMUX_PANE command cursor "$@"

unset TMUX
unset TMUX_PANE
exec command cursor "$@"

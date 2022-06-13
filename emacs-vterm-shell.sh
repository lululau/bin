#!/bin/bash

open -a Emacs
/usr/local/bin/emacsclient -q --eval '(progn (spacemacs/persp-switch-to-1) (lx/run-in-zsh-vterm "tmux-attach-or-create main" "*tmux-main*"))' > /dev/null 2>&1 &

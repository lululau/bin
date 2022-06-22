#!/bin/bash

open -a Emacs
/usr/local/bin/emacsclient -q --eval '(progn (spacemacs/persp-switch-to-1) (lx/run-in-vterm "~/bin/k9s" "*k9s*" nil t))' > /dev/null 2>&1 &

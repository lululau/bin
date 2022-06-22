#!/bin/bash

open -a Emacs
/usr/local/bin/emacsclient -q --eval '(progn (spacemacs/persp-switch-to-1) (vterm-mitmproxy-normal-proxy nil))' > /dev/null 2>&1 &

#!/bin/bash

open -a Emacs
/usr/local/bin/emacsclient -q --eval '(progn (spacemacs/persp-switch-to-1) (delete-other-windows) (helm-pry-vterm-arql))' > /dev/null 2>&1 &
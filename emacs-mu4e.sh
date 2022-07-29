#!/bin/bash

open -a Emacs
/usr/local/bin/emacsclient -q --eval "(call-interactively 'lx/open-mail-custom-layout-or-mu4e-main)" > /dev/null 2>&1 &

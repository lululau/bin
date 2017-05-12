#!/bin/bash

export PATH=/usr/local/bin:$PATH

if pgrep -q Emacs; then
    emacsclient -n --eval "(mu4e-update-mail-and-index t)"
else
    terminal-notifier -title 'New Mail' -message 'There are some new mails' -sender org.gnu.emacs
fi


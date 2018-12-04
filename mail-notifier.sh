#!/bin/bash

export PATH=/usr/local/bin:$PATH

if pgrep -q Emacs; then
  if [ "$1" = inbox ]; then
    emacsclient -n --eval "(mu4e-update-mail-and-index t)"
  # else
  #   offlineimap
  #   mv ~/Maildir/Archive/new/* ~/Maildir/Archive/cur/
  #   mv ~/Maildir/Deleted\ Messages/new/* ~/Maildir/Deleted\ Messages/cur/
  #   offlineimap
  fi
else
    terminal-notifier -title 'New Mail' -message 'There are some new mails' -sender org.gnu.emacs
fi


#!/bin/bash

if echo "$1" | grep -q '\(\.rb$\)\|\(.rake$\)\|\(Gemfile\)' && [ -n "$2" ]
then
    /usr/local/bin/emacsclient -n +"$2" "$1"
else
    open "$1"
fi

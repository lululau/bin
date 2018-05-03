#!/bin/bash

file_name=$1
osascript -e "tell app \"Alfred 3\" to browse \"$file_name\""

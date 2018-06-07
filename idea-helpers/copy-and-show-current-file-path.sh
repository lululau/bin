#!/bin/bash

file_name=$1
echo "$file_name" | pbcopy
osascript -e "display dialog \"$file_name\""

#!/bin/bash

if [ -n "$1" ]
then
  { "$@";} | tee >(pbcopy)
else
  perl -pe 's#\n## if eof' | pbcopy
fi



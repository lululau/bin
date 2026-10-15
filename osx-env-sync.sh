#!/bin/zsh
[[ -f $HOME/.zshenv ]] && source $HOME/.zshenv

grep "^export" $HOME/.zshenv | while IFS=' =' read ignoreexport envvar ignorevalue; do
  val="${(P)envvar}"
  if [[ -n "$val" ]]; then
    launchctl setenv "${envvar}" "$val"
  fi
done

if [ -e /opt/homebrew/bin/brew ]; then
  if launchctl getenv PATH | grep -v -q /opt/homebrew; then
    launchctl setenv PATH "/opt/homebrew/bin:/opt/homebrew/sbin:$(launchctl getenv PATH)"
  fi
fi


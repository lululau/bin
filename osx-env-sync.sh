grep "^export" $HOME/.zshenv | while IFS=' =' read ignoreexport envvar ignorevalue; do
  launchctl setenv "${envvar}" "${!envvar}"
done

if [ -e /opt/homebrew/bin/brew ]; then
  if launchctl getenv PATH | grep -v -q /opt/homebrew; then
    launchctl setenv PATH "/opt/homebrew/bin:/opt/homebrew/sbin:$(launchctl getenv PATH)"
  fi
fi


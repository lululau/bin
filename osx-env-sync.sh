grep "^export" $HOME/.zshenv | while IFS=' =' read ignoreexport envvar ignorevalue; do
  launchctl setenv ${envvar} ${!envvar}
done

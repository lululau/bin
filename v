#!/usr/bin/env zsh

VAGRANT_ROOT=$HOME/vagrant/arch

VAGRANT_PROCESS_COMMENT=arch_default

cd "$VAGRANT_ROOT"

if ps -ef | grep arch_default | grep -qv grep; then
  :
else
  echo -n "The VM is not running, start it now? (y/n) "
  read -q result
  if [ y = "$result" ]; then
    vagrant up
  else
    exit
  fi
fi

vagrant ssh

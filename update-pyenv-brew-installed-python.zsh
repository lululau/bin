#!/usr/bin/env zsh

if [ -z "$HOMEBREW_PREFIX" ]; then
  if [ -e "/opt/homebrew/bin/brew" ]; then
    HOMEBREW_PREFIX="/opt/homebrew"
  else
    HOMEBREW_PREFIX="/usr/local"
  fi
fi



mkdir -p ~/.pyenv/versions
ln -nfs $HOMEBREW_PREFIX/Cellar/python@2/2*(On[1]) ~/.pyenv/versions/
ln -nfs $HOMEBREW_PREFIX/Cellar/python@2/2*(On[1]) ~/.pyenv/versions/2
ln -nfs $HOMEBREW_PREFIX/Cellar/python@3.9/3*(On[1]) ~/.pyenv/versions/
ln -nfs $HOMEBREW_PREFIX/Cellar/python@3.9/3*(On[1]) ~/.pyenv/versions/3
ln -nfs $HOMEBREW_PREFIX/Cellar/python@3.8/3*(On[1]) ~/.pyenv/versions/3.8
cd ~/.pyenv/versions/3/bin
cp -Rf python3 python
cp -Rf pip3 pip
cd ~/.pyenv/versions/3.8/bin
cp -Rf python3 python
cp -Rf pip3 pip

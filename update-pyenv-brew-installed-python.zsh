#!/usr/bin/env zsh

mkdir -p ~/.pyenv/versions
ln -nfs /usr/local/Cellar/python@2/2*(On[1]) ~/.pyenv/versions/
ln -nfs /usr/local/Cellar/python@2/2*(On[1]) ~/.pyenv/versions/2
ln -nfs /usr/local/Cellar/python/3*(On[1]) ~/.pyenv/versions/
ln -nfs /usr/local/Cellar/python/3*(On[1]) ~/.pyenv/versions/3
cd ~/.pyenv/versions/3/bin
cp -Rf python3 python
cp -Rf pip3 pip

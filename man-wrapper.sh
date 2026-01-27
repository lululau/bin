#!/bin/bash

# 检查 stdout 是否为 TTY
if [ -t 1 ]; then
  :
else
  # stdout 不是 TTY，使用 cat
  export MANPAGER='cat'
fi

exec man "$@"

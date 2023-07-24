#!/bin/bash

TSINGHUA_MIRROR=$(cat <<EOF)
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ lunar main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ lunar main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ lunar-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ lunar-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ lunar-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ lunar-backports main restricted universe multiverse

# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ lunar-security main restricted universe multiverse
# # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ lunar-security main restricted universe multiverse

deb http://security.ubuntu.com/ubuntu/ lunar-security main restricted universe multiverse
# deb-src http://security.ubuntu.com/ubuntu/ lunar-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ lunar-proposed main restricted universe multiverse
# # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ lunar-proposed main restricted universe multiverse
EOF

PACKAGE_LIST=(
  "build-essential"
  "zsh"
  "git"
  "python3"
  "ruby"
  "rust-all"
  "golang"
  "nodejs"
)

FILES_MAP=(
  /Users/liuxiang/.oh-my-zsh:$HOME/
)

if [ ! -e "/etc/apt/sources.list.origin" ]; then
    echo "Backup sources.list"
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.origin
    sudo "bash -c 'echo \"$TSINGHUA_MIRROR\" > /etc/apt/sources.list'"
    sudo apt update
fi

for package in ${PACKAGE_LIST[@]}; do
  if ! dpkg -s $package >/dev/null 2>&1; then
    echo "Installing $package"
    sudo apt install -y $package
  else
    echo "$package is already installed"
  fi
done

for file in ${FILES_MAP[@]}; do
  src=${file%%:*}
  dst=${file#*:}
  if [ ! -e "$dst" ]; then
    echo "Copy $src to $dst"
    rsync -rzP /mnt/mac"$src" $dst
  else
    echo "$dst is already exists"
  fi
done

if [ ! -e /squashfs-root ]; then
  echo "Installing neovim"
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
  chmod u+x nvim.appimage
  sudo ./nvim.appimage --appimage-extract
  sudo mv squashfs-root /squashfs-root
  sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
  sudo ln -s /squashfs-root/AppRun /usr/bin/vim
  sudo ln -s /squashfs-root/AppRun /bin/vim
  sudo ln -s /squashfs-root/AppRun /usr/bin/vi
  sudo ln -s /squashfs-root/AppRun /bin/vi
fi

#!/bin/bash

PROG_DIR=$(cd "$(dirname "$0")"; pwd)
source "$PROG_DIR/baby/baby.sh"

last_arg_ind=$#
keys=${!last_arg_ind}

cmd=$(cat <<EOF
line_num=\$(cat ~/.ssh/authorized_keys | wc -l)
((line_num++))
echo >> ~/.ssh/authorized_keys
echo "$keys" >> ~/.ssh/authorized_keys
echo >> ~/.ssh/authorized_keys
sed -n "\$line_num,\\\$p" ~/.ssh/authorized_keys
EOF
)

arr._subarr user_hosts_args 0 $(($#-1)) "$@"

remote-do.sh "${user_hosts_args[@]}" "$cmd"

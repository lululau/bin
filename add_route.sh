#!/bin/bash

function filter() {
  grep -v -F -f <(perl -ne 'print if s/^.*?((\d+\.){3}\d+).*$/$1/' /etc/ppp/ip-up)
}

function replace() {
   perl -pe 's#.*#route '$1' $& "\${OLDGW}"#'
}

function up_cmd() {
  replace add
}

function down_cmd() {
  replace delete
}

function radd() {
  hosts=$(cat)
  if [ -z "$hosts" ]
  then
    exit
  fi
  echo "$hosts" | up_cmd
  echo "$hosts" | up_cmd >> /etc/ppp/backup/ip-up
  echo "$hosts" | up_cmd >> /etc/ppp/ip-up
  echo "$hosts" | down_cmd >> /etc/ppp/backup/ip-down
  echo "$hosts" | down_cmd >> /etc/ppp/ip-down
  
  OLDGW=`netstat -nr | grep '^default' | grep -v 'ppp' | sed 's/default *\([0-9\.]*\) .*/\1/'`
  eval "$(echo "$hosts" | up_cmd | sed 's#"${OLDGW}"#'$OLDGW'#')"
}

host=$1
if echo "$host" | grep -q -E '^[0-9\.]+$'
then
  # radd "$(filter "$host")"
  echo "$host" | filter | radd
else
  for i in $(seq 1 10)
  do
    ip_arr=$ip_arr$'\n'$(nslookup "$host" | sed -n '/answer:$/,$s#^Address: ##p')
  done
  ip_arr=$(echo "$ip_arr" | sed -n '/^$/!p' | sort | uniq)
  # radd "$(filter "$ip_arr")"
  echo "$ip_arr" | filter | radd
fi

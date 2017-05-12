#!/bin/bash

PROG_DIR=$(cd "$(dirname "$0")"; pwd)
source "$PROG_DIR/baby/baby.sh"

OPT_USER="supertool"
OPT_HOSTS=""
OPT_VERBOSE_1=false
OPT_VERBOSE_2=false


while getopts 'u:h:vV' arg
do
    case $arg in
        u ) OPT_USER="$OPTARG";;
        h ) OPT_HOSTS="$OPTARG";;
        v ) OPT_VERBOSE_1=true;;
        V ) OPT_VERBOSE_2=true;;
    esac
done
if ((OPTIND > 1))
then
    for i in $(seq 2 $OPTIND); do shift; done
fi
CMD="$1"
declare -a HOSTS
declare -a fields
str.split fields "," "$OPT_HOSTS"
for field in "${fields[@]}"
do
    declare -a user_hosts
    str.split user_hosts "@" "$field"
    if [ ${#user_hosts[@]} -eq 2 ]; then
        user="${user_hosts[0]}"
        hosts_str="${user_hosts[1]}"
    else
        user="$OPT_USER"
        hosts_str="${user_hosts[0]}"
    fi
    str.split begin_end - "$hosts_str"
    if [ ${#begin_end[@]} -eq 2 ]; then
        host_prefix=$(echo "${begin_end[0]}" | grep -o '[a-zA-Z_\-\.]*')
        begin=$(echo "${begin_end[0]}" | grep -o '[0-9]\+')
        end=$(echo "${begin_end[1]}" | grep -o '[0-9]\+')
        for host_num in $(seq $begin $end); do
            host="$host_prefix$host_num"
            HOSTS+=("$user@$host")
        done
    else
        HOSTS+=("$user@${begin_end[0]}")
    fi
done

arr.map HOSTS '
{
    echo "$1.mzhen.cn"
}    
' HOSTS

for host in "${HOSTS[@]}"; do

    if [ "$OPT_VERBOSE_1" == true -o "$OPT_VERBOSE_2" == true ]; then
        echo
        echo "$host"
        echo "===================================="
    fi
    if [ "$OPT_VERBOSE_2" == true ]; then
        echo
        echo "+---------- Commands ----------------"
        echo "$CMD" | perl -pe 's#^#|  #g'
        echo "+------------------------------------"
        echo
    fi
    ssh "$host" "$CMD"
done
#!/bin/bash

PROG_DIR=$(cd "$(dirname "$0")"; pwd)

for i in "$PROG_DIR/"test*.sh; do
    echo
    echo "$i"
    echo =================================================
    bash "$i"
done


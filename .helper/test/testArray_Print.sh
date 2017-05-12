#!/bin/bash

function testArray_Print() {

    a=(10 20 "h w" '$"' "'" '\ ')
    a_repr=$(arr._print "${a[@]}")
    expected=$(cat <<"EOF"
('10' '20' 'h w' '$"' ''\''' '\ ')
EOF
        )
    assertEquals "$expected" "$a_repr"
}


PROG_DIR=$(cd "$(dirname "$0")"; pwd)
source "$PROG_DIR/../functions.sh"
source /usr/lib/shunit2/src/shunit2
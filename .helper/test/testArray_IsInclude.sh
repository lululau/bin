#!/bin/bash

function testArray_IsInclude() {

    a=(10 20 "h w" '$"' "'" '\ ')
    assertTrue 'arr._is_include "10" "${a[@]}"'
    assertTrue 'arr._is_include "20" "${a[@]}"'
    assertTrue 'arr._is_include "h w" "${a[@]}"'
    assertTrue 'arr._is_include "\$\"" "${a[@]}"'
    assertTrue 'arr._is_include "'\''" "${a[@]}"'
    assertTrue 'arr._is_include "\\ " "${a[@]}"'
    assertFalse 'arr._is_include "30" "${a[@]}"'
    assertFalse 'arr._is_include "\$" "${a[@]}"'
    assertFalse 'arr._is_include "\"" "${a[@]}"'
    assertFalse 'arr._is_include "\\" "${a[@]}"'
    assertFalse 'arr._is_include "'\'\''" "${a[@]}"'
}


PROG_DIR=$(cd "$(dirname "$0")"; pwd)
source "$PROG_DIR/../functions.sh"
source /usr/lib/shunit2/src/shunit2
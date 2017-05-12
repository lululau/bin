#!/bin/bash

function testArrayIsInclude() {

    a=(10 20 "h w" '$"' "'" '\ ')
    assertTrue 'arr.is_include "10" "a"'
    assertTrue 'arr.is_include "20" "a"'
    assertTrue 'arr.is_include "h w" "a"'
    assertTrue 'arr.is_include "\$\"" "a"'
    assertTrue 'arr.is_include "'\''" "a"'
    assertTrue 'arr.is_include "\\ " "a"'
    assertFalse 'arr.is_include "30" "a"'
    assertFalse 'arr.is_include "\$" "a"'
    assertFalse 'arr.is_include "\"" "a"'
    assertFalse 'arr.is_include "\\" "a"'
    assertFalse 'arr.is_include "'\'\''" "a"'
}


PROG_DIR=$(cd "$(dirname "$0")"; pwd)
source "$PROG_DIR/../functions.sh"
source /usr/lib/shunit2/src/shunit2
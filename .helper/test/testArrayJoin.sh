#!/bin/bash

testArrayJoin_with_underscore() {
    a=(10 20 "h w" '$"' "'" '\ ')
    str="$(arr.join "____" "a")"
    expected=$(cat <<"EOF"
10____20____h w____$"____'____\ 
EOF
        )
    assertEquals "$expected" "$str"
    unset str
    unset expected
    assertNull "$str"
    assertNull "$expected"
}

testArrayJoin_with_single_quote() {
    a=(10 20 "h w" '$"' "'" '\ ')
    str="$(arr.join "'" "a")"    
    expected=$(cat <<"EOF"
10'20'h w'$"'''\ 
EOF
        )
    assertEquals "$expected" "$str"
    unset str
    unset expected
    assertNull "$str"
    assertNull "$expected"
}

testArrayJoin_with_double_quote() {
    a=(10 20 "h w" '$"' "'" '\ ')
    str="$(arr.join '"' "a")"    
    expected=$(cat <<"EOF"
10"20"h w"$""'"\ 
EOF
        )
    assertEquals "$expected" "$str"
    unset str
    unset expected
    assertNull "$str"
    assertNull "$expected"
}


testArrayJoin_with_dollar() {
    a=(10 20 "h w" '$"' "'" '\ ')
    str="$(arr.join '$' "a")"    
    expected=$(cat <<"EOF"
10$20$h w$$"$'$\ 
EOF
        )
    assertEquals "$expected" "$str"
    unset str
    unset expected
    assertNull "$str"
    assertNull "$expected"
}

testArrayJoin_with_backslash() {
    a=(10 20 "h w" '$"' "'" '\ ')
    str="$(arr.join '\' "a")"    
    expected=$(cat <<"EOF"
10\20\h w\$"\'\\ 
EOF
        )
    assertEquals "$expected" "$str"
    unset str
    unset expected
    assertNull "$str"
    assertNull "$expected"
}

PROG_DIR=$(cd "$(dirname "$0")"; pwd)
source "$PROG_DIR/../functions.sh"
source /usr/lib/shunit2/src/shunit2
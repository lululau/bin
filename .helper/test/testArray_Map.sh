#!/bin/bash

function testArray_Map_with_function_body_string() {

    a=(10 20 "h w" '$"' "'" '\ ')
    arr._map b '
    {
        echo "hello, $1"
    }
    ' "${a[@]}"
    b_repr=$(arr.print b)
    expected=$(cat <<"EOF"
('hello, 10' 'hello, 20' 'hello, h w' 'hello, $"' 'hello, '\''' 'hello, \ ')
EOF
        )
    assertEquals "$expected" "$b_repr"
}

function __test_hello() {
    echo "hello, $1"
}

function testArray_Map_with_function_name() {    
    a=(10 20 "h w" '$"' "'" '\ ')
    arr._map b __test_hello "${a[@]}"
    b_repr=$(arr.print b)
    expected=$(cat <<"EOF"
('hello, 10' 'hello, 20' 'hello, h w' 'hello, $"' 'hello, '\''' 'hello, \ ')
EOF
        )
    assertEquals "$expected" "$b_repr"
}

function testArray_Map_with_meta_characters() {

    a=(10 20 "h w" '$"' "'" '\ ')
    arr._map b "$(cat <<"EOF"
    {
        echo "hello,'\"\\\$ $1"
    }
EOF
)" "${a[@]}"
    b_repr=$(arr.print b)
    expected=$(cat <<"FOE"
('hello,'\''"\$ 10' 'hello,'\''"\$ 20' 'hello,'\''"\$ h w' 'hello,'\''"\$ $"' 'hello,'\''"\$ '\''' 'hello,'\''"\$ \ ')
FOE
        )
    assertEquals "$expected" "$b_repr"

}

PROG_DIR=$(cd "$(dirname "$0")"; pwd)
source "$PROG_DIR/../functions.sh"
source /usr/lib/shunit2/src/shunit2
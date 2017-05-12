#!/bin/bash

function testArrayGrep_with_function_body_string() {

    a=(10 20 "h w" '$"' "'" '\ ')
    arr.grep b '
    {
        echo "$1" | grep -q "[0-9h\$\\\\'\'']"
    }
    ' "a"
    b_repr=$(arr.print b)
    expected=$(arr.print a)
    assertEquals "$expected" "$b_repr"
}

function __test_hello() {
    echo "$1" | grep -q '[0-9h$\\'\'']'
}

function testArrayGrep_with_function_name() {

    a=(10 20 "h w" '$"' "'" '\ ')
    arr.grep b __test_hello "a"
    b_repr=$(arr.print b)
    expected=$(arr.print a)
    assertEquals "$expected" "$b_repr"    
}

function testArrayGrep_with_no_matched() {

    a=(10 20 "h w" '$"' "'" '\ ')
    arr.grep b '
    {
        return 1
    }
    ' "a"
    b_repr=$(arr.print b)
    c=()
    expected=$(arr.print c)
    assertEquals "$expected" "$b_repr"
}

function testArrayGrep_with_all_matched() {

    a=(10 20 "h w" '$"' "'" '\ ')
    arr.grep b '
    {
        return 0
    }
    ' "a"
    b_repr=$(arr.print b)
    expected=$(arr.print a)
    assertEquals "$expected" "$b_repr"
}

function testArrayGrep_with_digits_matched() {

    a=(10 20 "h w" '$"' "'" '\ ')
    arr.grep b '
    {
        echo "$1" | grep -q "[0-9]"
    }
    ' "a"
    b_repr=$(arr.print b)
    expected="('10' '20')"
    assertEquals "$expected" "$b_repr"
}

function testArrayGrep_with_no_digits_matched() {

    a=(10 20 "h w" '$"' "'" '\ ')
    arr.grep b '
    {
        echo "$1" | grep -qv "[0-9]"
    }
    ' "a"
    b_repr=$(arr.print b)
    expected="('h w' '\$\"' ''\''' '\ ')"
    assertEquals "$expected" "$b_repr"
}

PROG_DIR=$(cd "$(dirname "$0")"; pwd)
source "$PROG_DIR/../functions.sh"
source /usr/lib/shunit2/src/shunit2
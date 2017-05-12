#!/bin/bash

# example:
#     arr._join ", " "$@"
#     arr._join ", " "${my_arr[@]}"
# comments:
#     echo the joined string to stdout.
function arr._join() {
    local __delimiter=$1
    shift
    if [ -z "$1" ]
    then
        exit
    fi
    local __return_value=$1
    shift
    local __item
    for __item in "$@"
    do
        __return_value="${__return_value}${__delimiter}${__item}"
    done
    echo "$__return_value"
}

# example:
#     arr.join ", " "my_arr"  # my_arr is the name of some array variable
# comments:
#     echo the joined string to stdout.
function arr.join() {    
    local __arr_name=$2
    local __delimiter=$1
    __delimiter=${__delimiter//\'/\'\\\'\'}
    eval "arr._join '$__delimiter' \"\${$__arr_name[@]}\""
}

# example:
#     arr._map "my_new_array" "my_command" "$@"
#     arr._map "my_new_array" "my_command" "${my_arrray[@]}"
# comments:
#     execute "my_command" with the elememnt passed for every element of "$@" or "${my_array[@]}" 
#     assign the mapped array to "my_new_array"
function arr._map() {
    local __assign_array_name=$1
    shift
    local __map_func=$1
    shift
    local __map_func_lines=$(str.lines "$__map_func")    
    local __map_func_name="__tmp_func"
    if [ "$__map_func_lines" -gt 1 ]; then
        local __func_definition="
        function $__map_func_name()
        $__map_func
        "
        eval "$__func_definition"
    else
        __map_func_name="$__map_func"
    fi
    local __local_arr=()
    local __item
    for __item in "$@"
    do
        __item=${__item//\'/\'\\\'\'}
        local __new_item=$(eval "$__map_func_name '$__item'")
        __local_arr+=("$__new_item")
    done
    if [[ "${#__local_arr[@]}" == 0 ]]; then
        eval "$__assign_array_name=()"
    else
        local __joined_array=""
        local __i
        for __i in "${__local_arr[@]}"
        do
            __i=${__i//\'/\'\\\'\'}
            __joined_array="$__joined_array' '$__i"
        done
        __joined_array=${__joined_array#\' \'}
        eval "$__assign_array_name=('$__joined_array')"
    fi
    unset __tmp_func
}

# example:
#     arr._map "my_new_array" "my_command" my_array
# comments:
#     execute "my_command" with the elememnt passed for every element of "my_array" 
#     assign the mapped array to "my_new_array"
function arr.map() {
    local __func=$2
    __func=${__func//\'/\'\\\'\'}
    local __arr_name=$3
    eval "arr._map '$1' '$__func' \"\${$__arr_name[@]}\""
}

function arr._print() {
    local __tmp_arr
    arr._map __tmp_arr "$(cat <<'EOF'
{
    local __str=$1
    __str=${__str//\'/\'\\\'\'}
    echo "'$__str'"    
}
EOF
    )" "$@"
    echo "($(arr._join " " "${__tmp_arr[@]}"))"
}

function arr.print() {
    local arr_name=$1
    eval "arr._print \"\${$arr_name[@]}\""
}

function arr._grep() {
    local __assign_array_name=$1
    shift
    local __grep_func=$1
    shift
    local __grep_func_lines=$(str.lines "$__grep_func")
    local __grep_func_name="__tmp_func"
    if [ "$__grep_func_lines" -gt 1 ]; then
        local __func_definition="
        function $__grep_func_name()
        $__grep_func
        "
        eval "$__func_definition"
    else
        __grep_func_name="$__grep_func"
    fi
    local __local_arr=()
    local __item
    for __item in "$@"
    do
        local __quoted=${__item//\'/\'\\\'\'}
        local __eval_str=$(cat <<EOF
        if $__grep_func_name '$__quoted'
        then
            echo true
        else
            echo false
        fi
EOF
)
        local __eval_result=$(eval "$__eval_str")
        if [ "$__eval_result" = true ]; then
            __local_arr+=("$__item")
        fi
    done
    if [[ ${#__local_arr[@]} == 0 ]]; then
        eval "$__assign_array_name=()"
    else
        local __joined_array=""
        local __i
        for __i in "${__local_arr[@]}"
        do
            __i=${__i//\'/\'\\\'\'}
            __joined_array="$__joined_array' '$__i"
        done
        __joined_array=${__joined_array#\' \'}
        eval "$__assign_array_name=('$__joined_array')"
    fi
    unset __tmp_func
}

function arr.grep() {
    local __func=$2
    __func=${__func//\'/\'\\\'\'}
    local __arr_name=$3
    eval "arr._grep '$1' '$__func' \"\${$__arr_name[@]}\""
}

function arr._is_include() {
    local __value=$1
    shift
    local __elem
    for __elem in "$@"
    do
        if [ "$__elem" = "$__value" ]; then
            return 0
        fi
    done
    return 1
}

function arr.is_include() {
    local value=$1
    value=${value//\'/\'\\\'\'}
    local arr_name=$2
    return $(eval "arr._is_include '$value' \"\${$arr_name[@]}\"; echo \$?")
}

function arr._each() {
    local func=$1
    shift
    local func_lines=$(str.lines "$func")
    local func_name="tmp_func"
    if [ "$func_lines" -gt 1 ]; then
        local func_definition="
        function $func_name()
        $func
        "
        eval "$func_definition"
    else
        func_name="$func"
    fi
    local elem
    local i=0
    for elem in "$@"
    do
        elem=${elem//\'/\'\\\'\'}
        eval "$func_name '$elem' '$i'"
        ((i++))
    done
    unset tmp_func
}

function arr.each() {
    local func=$1
    func=${func//\'/\'\\\'\'}
    local arr_name=$2
    eval "arr._each '$func' \"\${$arr_name[@]}\""
}

function arr._subarr() {
    local new_arr_name=$1
    shift
    local offset=$1
    shift
    local length=$1
    shift
    if [ "$offset" -gt 0 ]; then
        for i in $(seq 1 "$offset"); do
            shift
        done
    fi
    local joined_array=""
    for i in $(seq 1 "$length"); do
        local item=${!i}        
        item=${item//\'/\'\\\'\'}
        joined_array="$joined_array' '$item"
    done
    joined_array=${joined_array#\' \'}
    eval "$new_arr_name=('$joined_array')"
}

function arr.subarr() {    
    eval "arr._subarr '$1' '$2' '$3' \"\${$4[@]}\""
}

function arr._pop() {
    local new_arr_name=$1
    shift
    last_item=${!#}
    echo "$last_item"
    arr._subarr "$new_arr_name" 0 $(($# - 1)) "$@"
}

function arr.pop() {
    eval "arr._pop '$1' \"\${$2[@]}\""
}

function arr._push() {
    local new_arr_name=$1
    shift
    local push_val=$1
    push_val=${push_val//\'/\'\\\'\'}
    shift
    arr._grep "$new_arr_name" true "$@"
    eval "$new_arr_name+=('$push_val')"
}

function arr.push() {
    local push_val=$2
    push_val=${push_val//\'/\'\\\'\'}
    eval "arr._push '$1' '$push_val' \"\${$3[@]}\""
}

function arr._shift() {
    local new_arr_name=$1
    shift
    first_item=$1
    echo "$first_item"
    arr._subarr "$new_arr_name" 1 $(($# - 1)) "$@"    
}

function arr.shift() {
    eval "arr._shift '$1' \"\${$2[@]}\""
}

function arr._unshift() {
    local new_arr_name=$1
    shift
    local unshift_val=$1
    unshift_val=${unshift_val//\'/\'\\\'\'}
    shift    
    local joined_array=""
    for i in "$@"
    do
        i=${i//\'/\'\\\'\'}
        joined_array="$joined_array' '$i"
    done
    joined_array=${joined_array#\' \'}
    eval "$new_arr_name=('$unshift_val' '$joined_array')"
}

function arr.unshift() {
    local unshift_val=$2
    unshift_val=${unshift_val//\'/\'\\\'\'}
    eval "arr._unshift '$1' '$unshift_val' \"\${$3[@]}\""
}

function arr._reverse() {
    local new_arr_name=$1
    shift
    local arr_size=$#
    local joined_array=""
    for i in $(seq $# 1); do
        local item=${!i}
        item=${item//\'/\'\\\'\'}
        joined_array="$joined_array' '$item"
    done
    joined_array=${joined_array#\' \'}
    eval "$new_arr_name=('$joined_array')"
}

function arr.reverse() {
    eval "arr._reverse '$1' \"\${$2[@]}\""
}

function arr._first() {
    local tmp_arr
    arr._shift tmp_arr "$@"
    unset tmp_arr
}

function arr.first() {
    eval "arr._first \"\${$1[@]}\""
}

function arr._last() {
    local tmp_arr
    arr._pop tmp_arr "$@"
    unset tmp_arr
}

function arr.last() {
    eval "arr._last \"\${$1[@]}\""
}

function arr._size() {
    echo $#
}

function arr.size() {
    eval "arr._size \"\${$1[@]}\""
}

function arr._length() {
    arr._length "$@"
}

function arr.length() {
    arr.size "$@"
}

function arr._copy() {
    local new_arr_name=$1
    shift
    eval "$new_arr_name=$(arr._print "$@")"
}

function arr.copy() {
    eval "arr._copy '$1' \"\${$2[@]}\""
}

function arr._cp() {
    arr._copy "$@"
}

function arr.cp() {
    arr.copy "$@"
}

function arr.range() {
    local arr_var_name=$1
    local start=$2
    local end=$3
    local step="$4"
    if [ -z "$step" ]; then
        step=1
    fi
    eval "$arr_var_name=($(seq "$start" "$step" "$end"))"
}

function str.split() {
    local arr_name=$1
    local splitor=$2
    local string=$3
    local arr_repr="($(echo "$string" | perl -lne 'chomp;print join " ", map {s#\\#\\\\#g;s#"#\\"#g;s#\$#\\\$#g;qq/"$_"/} split "'${splitor}'"'))"
    eval "$arr_name=$arr_repr"
}

function str.reverse() {
    echo "$1" | perl -lpe '$_=reverse <>'
}

function str.size() {
    echo ${#1}
}

function str.length() {
    str.size "$@"
}

function str.replace() {
    local s_pattern=$1
    local str=$2
    echo "$str" | perl -pe "$s_pattern"
}

function str.lines() {
    echo "$1" | wc -l | grep -o '[0-9]*' --color=none
}

function num.times() {
    local __help=$(cat <<"EOF"
        hahahaha
EOF
        )
    func.help "$__help" "$@" && return 0
    local __i
    local times=$1
    local func=$2
    local func_lines=$(str.lines "$func")
    local func_name="tmp_fuc"

    if [ "$func_lines" -gt 1 ]; then
        local func_definition="
        function $func_name()
        $func
        "
        eval "$func_definition"
    else
        func_name="$func"
    fi
    for __i in $(seq 1 "$times"); do
        eval "$func_name '$((__i - 1))'"
    done
    unset tmp_func
}

function func.help() {
    if [ "$#" -eq 1 ]; then
        "$1" --help
        return 0
    fi
    if [ "$2" == "--help" -o "$2" == "-h" ]; then
        echo "$1"
        return 0
    else
        return 1
    fi
}
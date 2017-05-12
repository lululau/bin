#!/bin/bash

function map_set() {
  map_name=$1
  key=$2
  value=$3  
  eval "${map_name}_$key=$value"
  eval "keys_len=\${#${map_name}_keys[@]}"
  eval "${map_name}_keys[$keys_len]=$key"
}

function map_get() {
  map_name=$1
  key=$2
  var_name="${map_name}_$key"
  echo ${!var_name}
}

function map_keys() {
  map_name=$1
  eval "echo \${${map_name}_keys[@]}"
}

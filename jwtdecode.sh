#!/bin/zsh

base64_decode() {
  local input=$1
  local remainder=$(( ${#input} % 4 ))
  if [ $remainder -eq 2 ]; then
    input="${input}=="
  elif [ $remainder -eq 3 ]; then
    input="${input}="
  fi
  echo "$input" | tr '_-' '/+' | base64 -d
}

jwt_token=$(cat)
token_components=(${(s/./)jwt_token})
header=$(base64_decode $token_components[1])
payload=$(base64_decode $token_components[2])
signature=$token_components[3]

cat <<EOF
Header: $header
Payload: $payload
Signature: $signature
EOF

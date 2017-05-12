#!/bin/bash

hostname='www.yuntiprivaten.com'
session_name=www_yuntiprivaten_com

function sign_in() {

  echo "Session timeout, now re-sign-in."
  echo -n "Username: "
  read username
  echo -n "Password: "
  stty -echo
  read password
  stty echo
  echo "Sign in start..."
  csrf_token=$(http --verify=no --session=$session_name https://$hostname/users/sign_in | ack 'name="authenticity_token".*?value="(.*?)"' --output='$1')
  if http -ph --verify=no -f --session=$session_name https://$hostname/users/sign_in \
    utf8=✓ \
    authenticity_token="$csrf_token" \
    "user[login]=$username" \
    "user[password]=$password" \
    "user[remember_me]=0" \
    "user[remember_me]=1" \
    commit=登录  | grep -q /admin
  then
    echo "Sign in success."
  else
    echo "Sign in failed."
  fi

}

function print_info() {
  http --check-status -ph --verify=no --session=$session_name https://$hostname/admin/accountings &> /dev/null
  if [ $? -eq 3 ]
  then
    sign_in
  fi
  echo '=============================连接=============================='
  http --check-status --verify=no --session=$session_name https://$hostname/admin/accountings | cattable | pable -d '\t'
  echo
  echo '===================================================服务器====================================================='
  http --check-status --verify=no --session=$session_name https://$hostname/admin/servers | cattable | pable -d '\t'
}

print_info

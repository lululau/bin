#!/bin/sh

refr() {
  acc=100000000000
  # mac=$(cat /dev/urandom | sed 's/[^0-9A-F]\+//g' | awk -v ORS='' 1 | head -c12 | sed 's/../&-/g;s/.$//')
  mac=$(ruby -e 'puts 6.times.map {"%02x" % rand(256)}*"-"' | tr 'a-f' 'A-F')
  reqsn=00TF$(date '+%Y%m%d%H%M')009262
  # comp=BFEBFBFF$(cat /dev/urandom | sed 's/[^0-9A-Z]\+//g' | awk -v ORS='' 1 | head -c18)
  comp=BFEBFBFF$(ruby -e "puts ([*'0'..'9']+[*'A'..'Z']).sample(18)*''")
  inf=$(wget -O- "http://bj.wokuan.cn/web/startenrequest.php?ComputerMac=${mac}&ADSLTxt=${acc}&Type=3&reqsn=${reqsn}&oem=00&ComputerId=${comp}" 2>/dev/null | grep 'id="webcode"')

  # _acc=$(echo -n "$inf" | sed 's#.*&cn=\([^&]\+\)&.*#\1#g')
  # _rnd=$(echo -n "$inf" | sed 's#.*&random=\([^&<]\+\)[&<].*#\1#g')
  # _gus=$(echo -n "$inf" | sed 's#.*&gus=\([^&]\+\)&.*#\1#g')
  # _old=$(echo -n "$inf" | sed 's#.*&old=\([^&]\+\)&.*#\1#g')
  # _stu=$(echo -n "$inf" | sed 's#.*&stu=\([^&]\+\)&.*#\1#g')

  _acc=$(echo -n "$inf" | gsed 's#.*&cn=\([^&]\+\)&.*#\1#g')
  _rnd=$(echo -n "$inf" | gsed 's#.*&random=\([^&<]\+\)[&<].*#\1#g')
  _gus=$(echo -n "$inf" | gsed 's#.*&gus=\([^&]\+\)&.*#\1#g')
  _old=$(echo -n "$inf" | gsed 's#.*&old=\([^&]\+\)&.*#\1#g')
  _stu=$(echo -n "$inf" | gsed 's#.*&stu=\([^&]\+\)&.*#\1#g')
}

prt() {
  echo "_acc: $_acc"
  echo "_rnd: $_rnd"
  echo "_gus: $_gus"
  echo "_old: $_old"
  echo "_stu: $_stu"
}

stop() {
  wget -O- "http://bj.wokuan.cn/web/lowerspeed.php?ContractNo=${_acc}&round=${_rnd}" > /dev/null 2>&1
}

boo() {
  wget -O- "http://bj.wokuan.cn/web/improvespeed.php?ContractNo=${_acc}&up=${_gus}&old=${_old}&round=${_rnd}" > /dev/null 2>&1
}

if [ "$1" = '-i' ]
then
  refr
  prt
elif [ "$1" = '-s' ]
then
  refr
  prt
  stop
  refr
  prt
elif [ "$1" = '-b' ]
then
  refr
  prt
  boo
  refr
  prt
else
  refr
  while :
  do 
    if [ "$_stu" = 0 ]; then break; fi
    stop
    refr
    sleep 2
  done

  refr
  while :
  do 
    if [ "$_stu" = 1 ]; then break; fi
    boo
    refr
    sleep 2
  done
fi

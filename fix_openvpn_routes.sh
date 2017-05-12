#!/bin/bash

TUN_GW=$(netstat -nr | grep tun | grep '^0/1' | perl -pe 's#^0/1\s*([\d\.]+).*$#$1#')

route delete 0.0.0.0/1 $TUN_GW
route delete 128.0.0.0/1 $TUN_GW
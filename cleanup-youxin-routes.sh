#!/bin/bash

netstat -nr | awk '$4=="tun0" && $1!=$2 {print "route delete "$1" -interface tun0;"}END{print "route add 172.16.0.0/16 -interface tun0; route add 10.0.0.0/8 -interface tun0;"}' | sudo bash


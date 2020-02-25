#!/bin/bash

sudo bash <<EOF
route add 172.16.0.0/16 10.132.1.227
route add 10.0.0.0/8 10.132.1.227;
route add 116.213.205.147 10.132.1.227;
EOF

#!/bin/bash

route delete 211.151.139.192/26 192.168.1.1
route delete 211.151.139.196/32 192.168.1.1
route delete 211.151.151.0/25   192.168.1.1
route delete 211.151.165.0/24   192.168.1.1
route delete 192.168.1.26   10.32.30.254

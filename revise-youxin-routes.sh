#!/bin/bash

sudo bash -c 'route delete 10.132/24 -interface utun0;
route delete 10.132.1/30 -interface utun0;
route delete 10.132.1.4/31 -interface utun0;
route delete 10.132.1.6 -interface utun0;
route delete 10.132.1.8/29 -interface utun0;
route delete 10.132.1.16/28 -interface utun0;
route delete 10.132.1.32/27 -interface utun0;
route delete 10.132.1.64/26 -interface utun0;
route delete 10.132.1.128/26 -interface utun0;
route delete 10.132.1.192/27 -interface utun0;
route delete 10.132.1.224/28 -interface utun0;
route delete 10.132.1.240/29 -interface utun0;
route delete 10.132.1.248/30 -interface utun0;
route delete 10.132.1.252 -interface utun0;
route delete 10.132.1.254/31 -interface utun0;
route delete 10.132.2/23 -interface utun0;
route delete 10.132.4/22 -interface utun0;
route delete 10.132.8/21 -interface utun0;
route delete 10.132.16/20 -interface utun0;
route delete 10.132.32/19 -interface utun0;
route delete 10.132.64/18 -interface utun0;
route delete 10.132.128/17 -interface utun0;'

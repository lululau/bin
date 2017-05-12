#!/bin/bash

gsed -i '/^# Modified hosts start/,/# Modified hosts end/d' /etc/hosts

curl -s https://raw.githubusercontent.com/racaljk/hosts/master/hosts | gsed -n '/^# Modified hosts start/,/# Modified hosts end/p' >> /etc/hosts

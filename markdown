#!/bin/bash

hoedown --all-block --all-span --all-flags "$@" | gsed '1i\<link rel="stylesheet" href="/Users/liuxiang/Library/Application%20Support/MacDown/Styles/GitHub2.css" />'

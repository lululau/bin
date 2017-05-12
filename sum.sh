#!/bin/bash

perl -ne '$s+=$_;END{print "$s\n"}' "$@"

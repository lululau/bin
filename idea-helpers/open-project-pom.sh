#!/usr/bin/env zsh

source project-root.sh
project_name=$1
file_path=$2
project_root=$(cd "$(dirname "$file_path")"; project_root .)
idea "$project_root/pom.xml:1"

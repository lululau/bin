#!/bin/bash

module_path=$1
idea --line 1 "$module_path/pom.xml"
if [ -e "$module_path/../pom.xml" ]; then
    idea --line 1 "$module_path/../pom.xml"
fi

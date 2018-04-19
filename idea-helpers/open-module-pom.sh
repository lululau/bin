#!/bin/bash

module_path=$1
idea "$module_path/pom.xml:1"
if [ -e "$module_path/../pom.xml" ]; then
    idea "$module_path/../pom.xml:1"
fi

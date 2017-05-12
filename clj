#!/bin/bash

if [ 0 = $# ]
then
  lein repl
else
  lein_home=$(brew info leiningen | sed -n 3p | cut -d' ' -f1)
  clojure_jar_file_name=$(ls ${lein_home}/libexec)
  clojure_jar_file_path="$lein_home/libexec/$clojure_jar_file_name"
  java -cp "$clojure_jar_file_path" clojure.main "$@"
fi

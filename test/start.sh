#!/bin/bash

args=

function run {
  file=$1;
  if [ "${args[0]}" = "${file}" ]; then
    args=("${args[@]:1}");
  fi
  echo "";
  printf '"%s" ' "${args[@]}" | xargs echo "> DEBUG=leoric mocha -R dot --exit --timeout 5000 ${file}";
  printf '"%s" ' "${args[@]}" | DEBUG=leoric NODE_OPTIONS=--enable-source-maps xargs mocha -R dot --exit --timeout 5000 ${file} || exit $?;
}

##
# Run unit tests first in order catch bugs as soon as possible
function unit {
  # recursive glob nor available in bash 3
  # - https://unix.stackexchange.com/questions/49913/recursive-glob
  run "$(ls test/unit/{,drivers/,drivers/*/,adapters/,utils/}*.test.js)";
}

##
# integration tests
function integration {
  for file in $(ls test/integration/*.test.js); do run ${file}; done
}

##
# definition type tests
function dts {
  run "$(ls test/types/*.test.js)";
}

case $1 in
  unit)
    args=("${@:2}")
    npx tsc
    unit
    ;;
  integration)
    args=("${@:2}")
    npx tsc
    integration
    ;;
  dts)
    args=("${@:2}")
    npx tsc
    dts
    ;;
  *.js)
    args=("${@:1}")
    npx tsc
    run $1
    ;;
  *)
    args="$@"
    unit
    integration
    dts
    ;;
esac

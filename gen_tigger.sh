#!/bin/bash

# usage: ./gen_tigger.sh <compiler> <cases> <output>

compiler="$1"
cases="$2"
output="$3"

for f in $cases/*.eeyore; do
  name=`basename $f`
  out=$output/${name%.eeyore}.tigger
  $compiler -S -t $f -o $out 2> /dev/null
  if [ $? -ne 0 ]; then
    echo "failed on $f"
    rm $out
  fi
done

#!/bin/bash

# usage: ./gen_eeyore.sh <compiler> <cases> <output>

compiler="$1"
cases="$2"
output="$3"

for f in $cases/*.c; do
  name=`basename $f`
  out=$output/${name%.c}.eeyore
  $compiler -S -e $f -o $out 2> /dev/null
  if [ $? -ne 0 ]; then
    echo "failed on $f"
    rm $out
  fi
done

#!/bin/bash

# usage: ./gen_eeyore.sh <compiler> <cases> <output>

compiler="$1"
cases="$2"
output="$3"

shopt -s nullglob
for f in $cases/*.c $cases/*.sy; do
  name=`basename $f`
  out=$output/${name%.*}.eeyore
  $compiler -S -e $f -o $out 1> /dev/null 2> /dev/null
  if [ $? -ne 0 ]; then
    echo "failed on $f"
    rm $out
  fi
done

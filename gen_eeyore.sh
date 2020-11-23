#!/bin/bash

base=`dirname $0`
cases="$base/../cases"

for f in $cases/*.c; do
  name=`basename $f`
  out=$2/${name%.c}.eeyore
  $1 < $f > $out 2> /dev/null
  if [ $? -ne 0 ]; then
    echo "failed on $f"
    rm $out
  fi
done

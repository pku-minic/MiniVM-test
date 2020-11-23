#!/bin/bash

base=`dirname $0`

for f in $1/*.eeyore; do
  name=`basename $f`
  out=$3/${name%.eeyore}.tigger
  $2 < $f > $out 2> /dev/null
  if [ $? -ne 0 ]; then
    echo "failed on $f"
    rm $out
  fi
done

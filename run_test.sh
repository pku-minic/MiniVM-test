#!/bin/bash

# usage:
# ./run_test /path/to/minivm

# reference:
# https://github.com/TrivialCompiler/TrivialCompiler/blob/master/utils/run_case.sh


# test case directories (relative to script directory)
test_case_dirs=(
  "cases/ZhenbangYou"
  "cases/open-test-cases/eeyore/functional"
  "cases/open-test-cases/tigger/functional"
)


# count of total test cases
total=0
# count of passed test cases
pass=0


# command line for running MiniVM
if [[ "$OSTYPE" == "darwin"* ]]; then
  # define 'timeout' command on macOS
  function timeout { perl -e 'alarm shift; exec @ARGV' "$@"; }
fi
run="timeout 120"


# C compiler
cc="clang -O3"


# run the specific test case
#   arg1: command line for running test case
#   arg2: path to test case
#   arg3: prompt
function run_case {
  echo "  running ($3)..."

  # get name of test case
  local case_name="$2"
  local case_name=${case_name%.eeyore}
  local case_name=${case_name%.tigger}

  # get path to input/output/reference file
  local case_in="$case_name.in"
  local case_out="$2.temp"
  local case_ref="$case_name.out"

  # run the specific test case
  if [ -e "$case_in" ]; then
    $run $1 < "$case_in" > "$case_out"
  else
    $run $1 > "$case_out"
  fi
  local ret=$?

  # append return value to the end of output file
  if [ -z "$(tail -c 1 "$case_out")" ]; then
    # newline at EOF
    echo "$ret" >> "$case_out"
  else
    # no newline at EOF
    echo -en "\n$ret" >> "$case_out"
  fi

  # check the difference
  diff -w -B -u "$case_out" "$case_ref"
  local ret=$?

  # remove output file
  rm $case_out

  return $ret
}


# check the specific test case
#   arg1: command line for running MiniVM
#   arg2: path to test case
function check_case {
  echo "checking test case $2 ..."

  # get name of test case
  local case_name="$2"
  local case_name=${case_name%.eeyore}
  local case_name=${case_name%.tigger}

  # get path to C source file
  local case_c="$case_name.c"

  # compile the specific test case using C backend
  echo "  compiling..."
  $run $1 -c $2 -o $case_c
  $cc $case_c -o $case_name

  # run MiniVM & C backend
  run_case "$1 $2" $2 "MiniVM"
  local ret1=$?
  run_case "$case_name" $2 "C backend"
  local ret2=$?

  # remove output file
  rm $case_c $case_name

  # updated pass/fail info
  total=$((total+1))
  if [[ $ret1 -eq 0 && $ret2 -eq 0 ]]; then
    pass=$((pass+1))
  fi
}


# run all test cases
base_dir=`dirname $0`
for dir in ${test_case_dirs[@]}; do
  # run Eeyore test cases
  if ls $base_dir/$dir/*.eeyore 1> /dev/null 2>&1; then
    for f in $base_dir/$dir/*.eeyore; do
      check_case "$1" $f
    done
  fi
  # run Tigger test cases
  if ls $base_dir/$dir/*.tigger 1> /dev/null 2>&1; then
    for f in $base_dir/$dir/*.tigger; do
      check_case "$1 -t" $f
    done
  fi
done


# show summary info
if [ $pass -eq $total ]; then
  echo "PASSED ($pass/$total)"
else
  echo "FAILED ($pass/$total)"
fi
exit $((total-pass))

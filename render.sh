#!/bin/sh

input=$1
output="${1/.dot/.svg}"

set -x
dot -Tsvg -o"$output" "$input"

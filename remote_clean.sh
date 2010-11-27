#!/bin/sh

cd `dirname $0`
for i in `cat DIGEST`;
do
        rm $i;
done
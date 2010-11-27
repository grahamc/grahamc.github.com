#!/bin/sh

cd `dirname $0`
touch DIGEST
for i in `cat DIGEST`;
do
        rm $i;
done
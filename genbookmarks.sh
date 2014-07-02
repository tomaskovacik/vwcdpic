#!/bin/bash
pikovina=""
lines=`cat ${1}|wc -l`
for line in `seq 1 1 ${lines}`;
do
	echo "bookmarks."${line}"="`head -n ${line} ${1}|tail -n 1|sed 's/;/'${pikovina}'/g'`
done


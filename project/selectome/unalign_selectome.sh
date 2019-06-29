#!/bin/bash

INPATH=$1
OUTPATH=$2

mkdir -p $OUTPATH

FAS=`ls $INPATH`
for FILE in $FAS; do

    echo $FILE
    cp $INPATH/$FILE $OUTPATH
    sed -i "s/-//g" $OUTPATH/$FILE
    sed -i 's/^$//g' $OUTPATH/$FILE

done


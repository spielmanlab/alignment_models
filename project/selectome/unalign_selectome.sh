#!/bin/bash

#INPATH=$1
OUTPATH=$1

#mkdir -p $OUTPATH

FAS=`ls $OUTPATH`
for FILE in $FAS; do

    echo $FILE
   # cp $INPATH/$FILE $OUTPATH
    sed -i "s/-//g" $OUTPATH/$FILE
    sed -i 's/^$//g' $OUTPATH/$FILE
    sed -i 's/ PROTID/PROTID/g' $OUTPATH/$FILE 
    sed -i 's/ TRANSID/TRANSID/g' $OUTPATH/$FILE
    sed -i 's/ GENEID/GENEID/g' $OUTPATH/$FILE
    sed -i 's/ TAXID/TAXID/g' $OUTPATH/$FILE

done


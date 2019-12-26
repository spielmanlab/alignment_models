#!/bin/bash

set -eo pipefail


function remove_selectome_gaps () {
    ##########################################################################
    ## Takes a single argument, _the input file_, and processes it in place ##
    ##########################################################################
    FILE=$1
    echo $FILE
    gsed -i "s/-//g" $FILE
    gsed -i '/^$/d'  $FILE
    gsed -i 's/ PROTID/PROTID/g' $FILE
    gsed -i 's/ TRANSID/TRANSID/g' $FILE
    gsed -i 's/ GENEID/GENEID/g' $FILE
    gsed -i 's/ TAXID/TAXID/g' $FILE
}
export -f remove_selectome_gaps

FTP_PREFIX="ftp.lausanne.isb-sib.ch/databases/Selectome/Selectome_v06"

DATASETS=(Selectome_v06_Drosophila Selectome_v06_Euteleostomi)

for DATASET in "${DATASETS[@]}"; do
    for DATATYPE in aa nt; do
        echo "======================= ${DATASET}-${DATATYPE} ========================="
        FTPNAME=${DATASET}-${DATATYPE}_unmasked
        NAME001=${DATASET}-${DATATYPE}_001
        
        if [ -f ${NAME001}.tar.bz2 ]; then
            continue
        fi
        
        ## Retrieve
        echo "...Retrieving from FTP server"
        #continue
        wget -qr ftp://"${FTP_PREFIX}/${FTPNAME}.zip"
        mv ${FTP_PREFIX}/${FTPNAME}.zip .
        rm -rf ftp*
        
        ## Unzip
        echo "...Unpacking"
        unzip -qq ${FTPNAME}.zip
        
        ## Create 001 directory
        mkdir -p ${NAME001}
        
        ## Copy all 001 files in
        #cp ${FTPNAME}/*.001.*fas ${NAME001}
        echo "...Copying files"
        find ${FTPNAME} -name '*.001.*fas' -exec cp {} ${NAME001} \;        

        ## Remove original
        rm -r ${FTPNAME}
        rm -r ${FTPNAME}.zip
        
        ## Clean all 001 files of gaps
        echo "...Degapping"
        cd ${NAME001}
        find . | grep fas$ |  while read file; do remove_selectome_gaps "$file"; done 
        
        ## And back to compress for saving
        rm -f sed* # umm
        cd ..
        echo "...Compressing"
        tar -cvzf ${NAME001}.tar.bz2 ${NAME001}/
        rm -rf ${NAME001}/
        echo "Done!"
    done
done
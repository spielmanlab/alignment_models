#!/bin/bash

set -e

NAME=$1
THREADS=$2
BADLOG=$3
INPUT_NT_PATH=$4
INPUT_AA_PATH=$5
OUTPUT_PATH=$6

WDIR=/csm_data/spielman_lab/alignment_models/project/
cd $WDIR

### Execute analysis pipeline:
###### 1. Make perturbed alignments
###### 2. Run model selection
#NBOOT=49 #49 ## will be +1 with original, so 50 perturbations
export OMP_NUM_THREADS=$THREADS

NBOOT=49




NT_FAS=${NAME}.nt.fas
AA_FAS=${NAME}.aa.fas

ISOK=true
BADFILE=bad.out
COMPLETED=true
### Ensure there are both NT and AA versions
if [ -f ${INPUT_NT_PATH}/${NT_FAS} ] && [ -f ${INPUT_AA_PATH}/${AA_FAS} ]; then 
    
    for DATATYPE in NT AA; do

        if [ $DATATYPE == "NT" ]; then
            INPUT_DATA_PATH=${INPUT_NT_PATH}
            FASFILE=${NT_FAS}
        fi
        if [ $DATATYPE == "AA" ]; then
            INPUT_DATA_PATH=${INPUT_AA_PATH}
            FASFILE=${AA_FAS}
        fi

        BOOTDIR=${FASFILE}_alnversions_selectedmodels/
     
        if [ ! -d ${OUTPUT_PATH}/${BOOTDIR} ] && $ISOK; then
            echo $FASFILE
            
            echo "====================== PERTURBING ALIGNMENTS =========================="
            cp ${INPUT_DATA_PATH}/$FASFILE .
            python3 make_bootstrap_alignments.py $FASFILE $BOOTDIR $DATATYPE $NBOOT $THREADS $BADFILE

            if [ -f ${BOOTDIR}/${BADFILE} ]; then
                ISOK=false
                COMPLETED=false
                #exit 0
                rm $FASFILE
                rm -r $BOOTDIR
                break
            fi
            
            echo "====================== RUNNING MODEL SELECTION ========================"
            PREFIX="${FASFILE}_alnversion_"
            python3 run_iqtree_on_alignment_versions.py $BOOTDIR ${PREFIX} 1 50 $DATATYPE $THREADS
            
            #mv $BOOTDIR $OUTPUT_PATH
            rm $FASFILE
        else
            COMPLETED=false
            echo "${NAME} has already been run OR it contained duplicates" >> $BADLOG
        fi
        
    done
else
    COMPLETED=false
    echo "${NAME} does not have AA and NT versions" >> $BADLOG
fi

if [ $ISOK == false ] ; then 
    echo "${NAME} has duplicates" >> $BADLOG
fi
if [ $COMPLETED == true ]; then
   mv ${NAME}.*selectedmodels $OUTPUT_PATH
fi



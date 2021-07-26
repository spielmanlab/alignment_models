#!/bin/bash

set -eo pipefail

### Execute analysis pipeline:
###### 1. Make perturbed alignments
###### 2. Run model selection
#NBOOT=49 #49 ## will be +1 with original, so 50 perturbations


#############################################################
NAME=$1
THREADS=$2
BADLOG=$3
INPUT_NT_PATH=$4
INPUT_AA_PATH=$5
OUTPUT_PATH=$6
#############################################################
WDIR=/csm_data/spielman_lab/alignment_models/scripts
export OMP_NUM_THREADS=$THREADS
NBOOT=49
BOOT_START=1
BOOT_END=50

NT_FAS=${NAME}.nt.fas
AA_FAS=${NAME}.aa.fas

NODUPLICATES=true
BADFILE=bad.out
COMPLETED=true


### Ensure there are both NT and AA versions
if [ -f ${INPUT_NT_PATH}/${NT_FAS} ] && [ -f ${INPUT_AA_PATH}/${AA_FAS} ]; then 
    
    ### Run NT and AA versions through
    for DATATYPE in NT AA; do

        if [ $DATATYPE == "NT" ]; then
            INPUT_DATA_PATH=${INPUT_NT_PATH}
            FASFILE=${NT_FAS}
        fi
        if [ $DATATYPE == "AA" ]; then
            INPUT_DATA_PATH=${INPUT_AA_PATH}
            FASFILE=${AA_FAS}
        fi
        
        OUTNAME=${NAME}_${DATATYPE}
        BOOTDIR=${OUTNAME}/
        
        ## Skip if already run
        if [ -f ${OUTPUT_PATH}/${OUTNAME}_bestmodels.csv ]; then
            echo "Already run ${OUTNAME}_bestmodels.csv"
            continue
        else     
            ############### Run the pipeline ###########
            echo "====================== PERTURBING ${DATATYPE} ALIGNMENTS =========================="
            python3 make_bootstrap_alignments.py ${INPUT_DATA_PATH}/$FASFILE $OUTNAME $BOOTDIR $DATATYPE $NBOOT $THREADS $BADFILE

            ### If the perturbation failed due to duplicates, a file will have been created and we stop analyzing this $NAME
            if [ -f ${BOOTDIR}/${BADFILE} ]; then
                NODUPLICATES=false
                COMPLETED=false
                rm -r $BOOTDIR
                break
            fi          
            
            echo "====================== RUNNING ${DATATYPE} MODEL SELECTION ========================"
            python3 run_iqtree_on_alignment_versions.py $NAME $BOOTDIR ${BOOT_START} ${BOOT_END} $DATATYPE 10 ## only use 10 threads for iqtree

        fi
        
    done
else
    COMPLETED=false
    echo "${NAME} does not have AA and NT versions" >> $BADLOG
fi

if [ $NODUPLICATES == false ] ; then 
    echo "${NAME} has duplicate perturbed alignments" >> $BADLOG
fi

if [ $COMPLETED == true ]; then
   mv ${NAME}_*/*csv $OUTPUT_PATH
   mv ${NAME}_* $OUTPUT_PATH/..
fi



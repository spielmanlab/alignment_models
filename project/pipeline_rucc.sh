#!/bin/bash

NAME=$1
THREADS=$2
WDIR=/csm_data/spielman_lab/alignment_models/project/
cd $WDIR

### Execute analysis pipeline:
###### 1. Make perturbed alignments
###### 2. Run model selection
NBOOT=49 #49 ## will be +1 with original, so 50 perturbations
export OMP_NUM_THREADS=$THREADS


OUTPUT_NT_PATH=selectome_001_output/nt_output
OUTPUT_AA_PATH=selectome_001_output/aa_output
mkdir -p ${OUTPUT_NT_PATH}
mkdir -p ${OUTPUT_AA_PATH}

INPUT_NT_PATH=selectome/selectome_v06_Euteleostomi-nt_unmasked-UNALIGNED
INPUT_AA_PATH=selectome/selectome_v06_Euteleostomi-aa_unmasked-UNALIGNED

NT_FAS=${NAME}.nt.fas
AA_FAS=${NAME}.aa.fas

### Ensure there are both NT and AA versions
if [ -f ${INPUT_NT_PATH}/${NT_FAS} ] && [ -f ${INPUT_AA_PATH}/${AA_FAS} ]; then 

    for DATATYPE in NT AA; do

        if [ $DATATYPE == "NT" ]; then
            INPUT_DATA_PATH=${INPUT_NT_PATH}
            OUTPUT_DIRECTORY=${OUTPUT_NT_PATH}
            FASFILE=${NT_FAS}
        fi
        if [ $DATATYPE == "AA" ]; then
            INPUT_DATA_PATH=${INPUT_AA_PATH}
            OUTPUT_DIRECTORY=${OUTPUT_AA_PATH}
            FASFILE=${AA_FAS}
        fi

        BOOTDIR=${FASFILE}_alnversions_selectedmodels/
     
        if [ ! -d ${OUTPUT_DIRECTORY}/${BOOTDIR} ]; then
            echo $FASFILE
            
            echo "====================== PERTURBING ALIGNMENTS =========================="
            cp ${INPUT_DATA_PATH}/$FASFILE .
            python3 make_bootstrap_alignments.py $FASFILE $BOOTDIR $DATATYPE $NBOOT $THREADS

            echo "====================== RUNNING MODEL SELECTION ========================"
            python3 run_iqtree_on_alignment_versions.py $BOOTDIR $DATATYPE $THREADS
            mv $BOOTDIR $OUTPUT_DIRECTORY

            rm $FASFILE
        fi
        
    done

fi

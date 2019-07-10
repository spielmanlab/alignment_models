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

for DATATYPE in DNA AA; do

    if [ $DATATYPE == "DNA" ]; then
        INPUT_DATA_PATH=selectome/selectome_nt_unaligned_200-50
        OUTPUT_DIRECTORY=selectome_nt_output
       FASFILE=${NAME}.nt.fas
    fi
    if [ $DATATYPE == "AA" ]; then
      INPUT_DATA_PATH=selectome/selectome_aa_unaligned_200-50
      OUTPUT_DIRECTORY=selectome_aa_output
      FASFILE=${NAME}.aa.fas
    fi
    #mkdir -p ${OUTPUT_DIRECTORY}

    echo $FASFILE
    BOOTDIR=${FASFILE}_alnversions/
     
    
    if [ ! -f ${OUTPUT_DIRECTORY}/${FASFILE}_alnversion_24_models.csv ]; then
        echo "    Perturbing alignments"
        cp ${INPUT_DATA_PATH}/$FASFILE .
        python3 make_bootstrap_alignments.py $FASFILE $BOOTDIR $DATATYPE $NBOOT $THREADS

       echo "    Running model selection"
       python3 run_iqtree_on_alignment_versions.py $BOOTDIR $DATATYPE $THREADS
       mv $BOOTDIR/*csv $OUTPUT_DIRECTORY
       cp -r $BOOTDIR $OUTPUT_DIRECTORY
   fi
done

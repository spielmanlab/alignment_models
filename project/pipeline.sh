#!/bin/bash

### Execute analysis pipeline:
###### 1. Make perturbed alignments
###### 2. Run model selection


WDIR=`pwd`
INPUT_DATA_PATH=selectome/selectome_aa_subset
cd ${INPUT_DATA_PATH}
INPUT_FILES=`ls *fas`
cd $WDIR

DATATYPE="AA" #AA or DNA
NBOOT=49  #49 ## will be +1 with original, so 50 perturbations
THREADS=20  #15
export OMP_NUM_THREADS=$THREADS

OUTPUT_DIRECTORY=selectome_aa_subset_output
mkdir -p ${OUTPUT_DIRECTORY}

for FASFILE in ${INPUT_FILES}; do 

    echo $FASFILE
    BOOTDIR=${FASFILE}_alnversions/
    
    echo "    Perturbing alignments"
    cp ${INPUT_DATA_PATH}/$FASFILE .
    python3 make_bootstrap_alignments.py $FASFILE $BOOTDIR $DATATYPE $NBOOT $THREADS
    rm $FASFILE
    
    
    echo "    Running model selection"
    python3 run_iqtree_on_alignment_versions.py $BOOTDIR $DATATYPE $THREADS
    
    mv $BOOTDIR $OUTPUT_DIRECTORY
    cd $OUTPUT_DIRECTORY
    mv $BOOTDIR/*csv .
    cd $WDIR

done
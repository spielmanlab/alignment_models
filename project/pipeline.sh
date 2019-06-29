#!/bin/bash

### Execute analysis pipeline:
###### 1. Make perturbed alignments
###### 2. Run model selection


INPUT-DATA-PATH=selectome/selectome_aa_subset
INPUT-FILES=`ls ${INPUT-DATA-PATH}/*fas`

DATATYPE="protein" #dna
NBOOT=49 ## will be +1 with original, so 50 perturbations
THREADS=15
export OMP_NUM_THREADS=$THREADS

OUTPUT-DIRECTORY=selectome_aa_subset_output
mkdir -p $OUTPUT-DIRECTORY

for FASFILE in $INPUT-FILES; do 

    echo $FASFILE
    
    echo "    Perturbing alignments"
    python3 make_bootstrap_alignments.py $INPUT-DATA-PATH/$FASFILE $OUTPUT-DIRECTORY $DATATYPE $NBOOT $THREADS
    
    echo "    Running model selection"
    python3 run_iqtree_on_alignment_versions.py $OUTPUT-DIRECTORY $THREADS
    
    
    exit 0
done
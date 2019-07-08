#!/bin/bash

### Execute analysis pipeline:
###### 1. Make perturbed alignments
###### 2. Run model selection
THREADS=20
NBOOT=49 #49 ## will be +1 with original, so 50 perturbations
DATATYPE="DNA" #or DNA
WDIR=`pwd`

export OMP_NUM_THREADS=$THREADS
INPUT_DATA_PATH=selectome/selectome_v06_Euteleostomi-nt_unmasked-UNALIGNED
OUTPUT_DIRECTORY=selectome_nt_output
mkdir -p ${OUTPUT_DIRECTORY}

cd ${INPUT_DATA_PATH}
INPUT_FILES=`ls *001*fas`
cd $WDIR


for FASFILE in ${INPUT_FILES}; do 

    MOVEBOOT=0
    MOVECSV=0
    echo $FASFILE
    BOOTDIR=${FASFILE}_alnversions/
    if [ ! -d ${OUTPUT_DIRECTORY}/$BOOTDIR ]; then
        echo "    Perturbing alignments"
        cp ${INPUT_DATA_PATH}/$FASFILE .
        python3 make_bootstrap_alignments.py $FASFILE $BOOTDIR $DATATYPE $NBOOT $THREADS
        rm $FASFILE
	MOVEBOOT=1
    fi
    

    if [ ! -f ${OUTPUT_DIRECTORY}/${FASFILE}_alnversion_1_models.csv ]; then
        echo "    Running model selection"
        python3 run_iqtree_on_alignment_versions.py $BOOTDIR $DATATYPE $THREADS
        MOVECSV=1
    fi

    if [ $MOVEBOOT -eq 1 ]; then	
        mv $BOOTDIR $OUTPUT_DIRECTORY
    fi

    if [ $MOVECSV -eq 1 ]; then
        cd $OUTPUT_DIRECTORY
        mv $BOOTDIR/*csv .
        cd $WDIR
    fi

done

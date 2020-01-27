#!/bin/bash
#SBATCH --job-name=aln_modelsel
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=1000
#SBATCH -p csm
#SBATCH --array=1-1000

ADDON=1000
RAWLINE=${SLURM_ARRAY_TASK_ID}
LINE=$((ADDON + RAWLINE)) 
NAMEFILE=Euteleostomi.txt 
INLINE=$(sed "${LINE}q;d" ${NAMEFILE})
IFS=',' read -r NAME <<< "$INLINE"

TOPPATH=/csm_data/spielman_lab/alignment_models/project
cd $TOPPATH

OUTPUT_PATH=output_selectome
mkdir -p ${OUTPUT_PATH}

BADLOG=names_with_duplicates.txt

INPUT_NT_PATH=selectome/Selectome_v06_Euteleostomi-nt_001
INPUT_AA_PATH=selectome/Selectome_v06_Euteleostomi-aa_001

bash pipeline.sh ${NAME} 40 $BADLOG $INPUT_NT_PATH $INPUT_AA_PATH $OUTPUT_PATH

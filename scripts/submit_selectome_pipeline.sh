#!/bin/bash
#SBATCH --job-name=aln_modelsel
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=1000
#SBATCH -p csm
#SBATCH --array=1-1000

ADDON=2000
RAWLINE=${SLURM_ARRAY_TASK_ID}
LINE=$((ADDON + RAWLINE)) 
TYPE=Euteleostomi
NAMEFILE=${TYPE}.txt 
INLINE=$(sed "${LINE}q;d" ${NAMEFILE})
IFS=',' read -r NAME <<< "$INLINE"

TOPPATH=/csm_data/spielman_lab/alignment_models
cd $TOPPATH

OUTPUT_PATH=results/selected_models_output
mkdir -p ${OUTPUT_PATH}

BADLOG=names_with_duplicates_more.txt

INPUT_NT_PATH=selectome/Selectome_v06_${TYPE}-nt_001
INPUT_AA_PATH=selectome/Selectome_v06_${TYPE}-aa_001

bash scripts/pipeline.sh ${NAME} 40 $BADLOG $INPUT_NT_PATH $INPUT_AA_PATH $OUTPUT_PATH

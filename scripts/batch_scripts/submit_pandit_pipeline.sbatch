#!/bin/bash
#SBATCH --job-name=aln_modelsel
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=1000
#SBATCH -p csm
#SBATCH --array=1-254

LINE=${SLURM_ARRAY_TASK_ID}
NAMEFILE=pandit.txt 
INLINE=$(sed "${LINE}q;d" ${NAMEFILE})
IFS=',' read -r NAME <<< "$INLINE"

TOPPATH=/csm_data/spielman_lab/alignment_models
cd $TOPPATH

OUTPUT_PATH=results/pandit_selected_models_output
mkdir -p ${OUTPUT_PATH}

BADLOG=names_with_duplicates_more.txt

INPUT_NT_PATH=pandit/PANDIT_NT
INPUT_AA_PATH=pandit/PANDIT_AA

bash scripts/pipeline.sh ${NAME} 40 $BADLOG $INPUT_NT_PATH $INPUT_AA_PATH $OUTPUT_PATH

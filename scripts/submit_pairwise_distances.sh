#!/bin/bash
#SBATCH --job-name=hamming
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=1000
#SBATCH -p csm
#SBATCH --array=1-1000


PATH_TO_DATA=/csm_data/spielman_lab/ref50_only/

LINE=${SLURM_ARRAY_TASK_ID}
NAMEFILE=nt2.txt
INLINE=$(sed "${LINE}q;d" ${NAMEFILE})
IFS=',' read -r NAME <<< "$INLINE"

TOPPATH=/csm_data/spielman_lab/alignment_models
cd $TOPPATH
cd scripts

OUTPUT_PATH=pairwise_distances/
mkdir -p ${OUTPUT_PATH}

python3 calculate_pairwise_distances.py ${NAME} ${PATH_TO_DATA} ${OUTPUT_PATH}

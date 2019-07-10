#!/bin/bash
#SBATCH --job-name=aln_modelsel
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=1000
#SBATCH -p csm
#SBATCH --array=1-200


LINE=${SLURM_ARRAY_TASK_ID}

INLINE=$(sed "${LINE}q;d" all_aa_200-50.txt)
IFS=',' read -r NAME <<< "$INLINE"

TOPPATH=/csm_data/spielman_lab/alignment_models/project
cd $TOPPATH

bash pipeline_rucc.sh ${NAME} 45

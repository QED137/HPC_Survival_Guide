#!/bin/bash
# The smallest useful job script.
#   mkdir -p logs && sbatch minimal.sbatch

#SBATCH --job-name=hello
#SBATCH --partition=dev_cpu
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00
#SBATCH --output=logs/hello_%j.out

cd "$SLURM_SUBMIT_DIR"

echo "job $SLURM_JOB_ID on $(hostname)   $(date)"
echo "submitted from: $SLURM_SUBMIT_DIR"
echo "cores: ${SLURM_CPUS_PER_TASK:-1}"

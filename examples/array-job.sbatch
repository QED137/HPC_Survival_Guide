#!/bin/bash
# A parameter sweep as a job array.
#
#   sbatch --array=0-19%5 array-job.sbatch
#
# 20 tasks, at most 5 running at once. The throttle matters: without it
# you can monopolise a queue and annoy everyone.
#
# Resubmit a single failed task with:
#   sbatch --array=7 array-job.sbatch

#SBATCH --job-name=sweep
#SBATCH --partition=cpu
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --output=logs/sweep_%A_%a.out

set -euo pipefail
cd "$SLURM_SUBMIT_DIR"

module load devel/python/3.12.3-gnu-14.2
source .venv/bin/activate
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-1}

TASK=${SLURM_ARRAY_TASK_ID}
OUT="output/chunk_${TASK}.h5"

# Resumability: skip work already done, so a resubmit costs nothing.
if [[ -f "$OUT" ]]; then
    echo "SKIP task $TASK -- $OUT exists"
    exit 0
fi

echo "task $TASK on $(hostname)   $(date)"
python3 generate.py --chunk "$TASK" --out "$OUT"

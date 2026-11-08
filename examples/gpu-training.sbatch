#!/bin/bash
# A full GPU training run.
#
# Note: no --mem. On GPU partitions that allocate memory per GPU,
# setting it causes "Requested node configuration is not available".

#SBATCH --job-name=train
#SBATCH --partition=gpu_h100
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=16
#SBATCH --time=08:00:00
#SBATCH --output=logs/train_%j.out
#SBATCH --error=logs/train_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=you@example.edu

set -euo pipefail
cd "$SLURM_SUBMIT_DIR"

module load devel/python/3.12.3-gnu-14.2
source .venv/bin/activate

# Stop BLAS from oversubscribing the allocated cores.
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-1}
export MKL_NUM_THREADS=$OMP_NUM_THREADS

echo "job $SLURM_JOB_ID on $(hostname)   $(date)"
nvidia-smi --query-gpu=name --format=csv,noheader
python3 -c "import torch; print(torch.__version__, torch.cuda.is_available())"

python3 train.py --epochs 200 --batch 32 --out runs/full

echo "finished $(date)"

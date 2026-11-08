#!/bin/bash
# A 25-minute probe on a development GPU queue.
#
# Run this BEFORE any long job. It proves the partition is right, the
# environment comes up, the GPU is visible and the data loads -- for
# almost no cost. A probe that fails in two minutes saves you a day.

#SBATCH --job-name=probe
#SBATCH --partition=dev_gpu_h100
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --time=00:25:00
#SBATCH --output=logs/probe_%j.out

set -euo pipefail
cd "$SLURM_SUBMIT_DIR"

module load devel/python/3.12.3-gnu-14.2
source .venv/bin/activate

echo "=== host $(hostname)"
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
python3 -c "import torch; print('=== torch', torch.__version__, '| cuda', torch.cuda.is_available())"

# A deliberately tiny version of the real run.
python3 train.py --n-train 500 --epochs 5 --out runs/probe

# Slurm cheat sheet

## Submit

```bash
sbatch job.sbatch                            # submit
sbatch --test-only ... --wrap="hostname"     # dry run: would it start, and when?
sbatch --array=0-19%5 job.sbatch             # array, 5 concurrent
sbatch --dependency=afterok:12345 next.sbatch
```

## Watch

```bash
squeue -u $USER                  # PD = pending, R = running
squeue -u $USER --start          # estimated start time
```

## Inspect

```bash
sacct -j 12345 --format=JobID,State,Elapsed,MaxRSS,ExitCode
seff 12345
scontrol show job 12345
```

## Cancel

```bash
scancel 12345          scancel 12345_3          scancel -u $USER
```

## Resources

```bash
sinfo -s                         # partitions and limits
sinfo -t idle -o "%20P %6D"      # free right now
scontrol show partition gpu_h100
```

## Interactive (debugging only)

```bash
salloc --partition=dev_gpu --gres=gpu:1 --time=00:30:00
hostname                         # always confirm where you landed
```

## Transfer

```bash
rsync -avP file user@cluster:/path/        # run from the machine WITH the file
sha256sum file                             # compare both sides
```

## Modules

```bash
module avail | grep -i python
module spider pytorch
module load devel/python/3.12.3-gnu-14.2
module list ; module purge
```

## Job script skeleton

```bash
#!/bin/bash
#SBATCH --job-name=run
#SBATCH --partition=gpu_h100
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=16
#SBATCH --time=04:00:00
#SBATCH --output=logs/run_%j.out

cd "$SLURM_SUBMIT_DIR"              # jobs start in $HOME
module load devel/python/3.12.3-gnu-14.2
source .venv/bin/activate
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-1}

python3 train.py
```

Remember `mkdir -p logs` before submitting.

## Exit codes

| | |
|---|---|
| `0:0` | success |
| `127` | command not found — module or venv missing |
| `137` | killed, usually out of memory |
| `139` | segfault — compiled library, often architecture mismatch |

## Useful job variables

`$SLURM_JOB_ID` · `$SLURM_SUBMIT_DIR` · `$SLURM_ARRAY_TASK_ID` ·
`$SLURM_CPUS_PER_TASK`

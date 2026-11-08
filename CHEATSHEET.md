# Slurm cheat sheet

Commands and options can vary between clusters. Replace example partition,
module, account, and resource names with values supported by your site.

## Submit jobs

```bash
sbatch job.sbatch
sbatch --test-only --wrap="hostname"       # validate a simple job request
sbatch --array=0-19%5 job.sbatch           # tasks 0–19; at most 5 at once
sbatch --dependency=afterok:12345 next.sbatch
```

`--test-only` checks whether Slurm accepts the request; it does not run the
job. Use `squeue --start` to see an estimated start time after submission.

## Monitor jobs

```bash
squeue -u "$USER"                          # PD = pending, R = running
squeue -j 12345
squeue -u "$USER" --start                 # estimated start time
watch -n 5 'squeue -u "$USER"'
```

## Inspect jobs

```bash
sacct -j 12345 --format=JobID,JobName,State,Elapsed,MaxRSS,ExitCode
scontrol show job 12345                   # current job details
seff 12345                                 # optional site-provided summary
```

For completed jobs, `sacct` is usually the most useful command. `seff` is not
installed on every cluster.

## Cancel jobs

```bash
scancel 12345                              # cancel one job
scancel 12345_3                            # cancel one array task
scancel -u "$USER"                         # cancel all your jobs
```

## Check partitions and resources

```bash
sinfo -s                                   # compact partition summary
sinfo -o "%20P %6a %10l %6D %12G %T"       # availability and limits
sinfo -t idle -o "%20P %6D %T"             # currently idle nodes
scontrol show partition gpu_h100
```

Use `scontrol show partition` to check the exact limits and configuration for
your cluster. GPU requests may use either `--gres=gpu:1` or `--gpus=1`,
depending on the site configuration.

## Interactive allocation

Use interactive jobs for debugging and short experiments, not production
training:

```bash
salloc --partition=dev_gpu --gres=gpu:1 --time=00:30:00
srun --pty bash                           # start a shell on the allocation
hostname                                  # confirm the compute node
nvidia-smi                                # confirm GPU access, if applicable
exit                                      # leave the compute-node shell
exit                                      # release the allocation
```

## Transfer files

Run the first command on your local machine to copy to the cluster:

```bash
rsync -avP local-file user@cluster:/path/
```

Run the second command on your local machine to copy from the cluster:

```bash
rsync -avP user@cluster:/path/file local-file
```

Compare checksums on both systems:

```bash
sha256sum file
```

## Environment modules

```bash
module avail | grep -i python
module spider pytorch                    # search module versions and prerequisites
module purge                             # start with a clean environment
module load devel/python/3.12.3-gnu-14.2
module list
```

## Job script skeleton

Create the output directory before submitting:

```bash
mkdir -p logs
sbatch job.sbatch
```

Example `job.sbatch`:

```bash
#!/bin/bash
#SBATCH --job-name=run
#SBATCH --partition=gpu_h100
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=16
#SBATCH --time=04:00:00
#SBATCH --output=logs/run_%j.out

set -euo pipefail
cd "$SLURM_SUBMIT_DIR"

module purge
module load devel/python/3.12.3-gnu-14.2
source .venv/bin/activate

export OMP_NUM_THREADS="${SLURM_CPUS_PER_TASK:-1}"
srun python3 train.py
```

The `#SBATCH` settings are cluster-specific. Add an account with
`#SBATCH --account=...` if your cluster requires one.

## Common exit codes

| Code | Meaning |
|---|---|
| `0:0` | job completed successfully |
| `127` | command not found; check the module or virtual environment |
| `137` | process was killed, often because of an out-of-memory condition |
| `139` | segmentation fault, often from a compiled dependency |

Also inspect the Slurm `State`, `Reason`, and `ExitCode` fields; exit codes
are not always sufficient to identify the cause of a failure.

## Useful Slurm variables

`$SLURM_JOB_ID` · `$SLURM_JOB_NAME` · `$SLURM_SUBMIT_DIR` ·
`$SLURM_ARRAY_JOB_ID` · `$SLURM_ARRAY_TASK_ID` · `$SLURM_CPUS_PER_TASK` ·
`$SLURM_GPUS`

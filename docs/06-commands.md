# 6. The commands worth knowing

Grouped by what you're trying to do.

## Submitting

```bash
sbatch job.sbatch                    # submit; prints a job ID
sbatch --test-only ... --wrap="cmd"  # would it run, and when? queues nothing
sbatch --export=ALL job.sbatch       # pass your current environment in
sbatch --array=0-19%5 job.sbatch     # 20 tasks, at most 5 at once
sbatch --dependency=afterok:12345 b.sbatch   # only if 12345 succeeded
```

Dependency types: `afterok` (success), `afterany` (either way),
`afternotok` (failure). Chaining stages this way lets you submit a whole
pipeline at once and walk away.

## Monitoring

```bash
squeue -u $USER                      # your jobs and their state
squeue -u $USER --start              # estimated start times (often pessimistic)
squeue -j 12345 -o "%T %R"           # one job: state and reason
watch -n 30 squeue -u $USER          # refresh every 30s
```

## Inspecting finished jobs

```bash
sacct -j 12345 --format=JobID,State,Elapsed,MaxRSS,ExitCode
sacct -u $USER --starttime=2026-11-01 --format=JobID,JobName,State,Elapsed
seff 12345                           # efficiency summary, where available
scontrol show job 12345              # everything Slurm knows (while queued/running)
```

`sacct` is what you reach for after a job disappears from `squeue`.
`MaxRSS` is peak memory actually used — compare it to what you requested and
adjust next time.

## Cancelling

```bash
scancel 12345                        # one job
scancel 12345_3                      # one array task
scancel -u $USER                     # everything you have queued or running
```

## Finding resources

```bash
sinfo -s                             # partitions, limits, node counts
sinfo -o "%P %G"                     # which partitions have GPUs
sinfo -t idle -o "%20P %6D"          # what's free right now
scontrol show partition gpu_h100     # time limit, default memory, defaults
```

Some sites restrict `sinfo` (you get `Access/permission denied`) and provide a
wrapper such as `sinfo_t_idle` instead.

## Interactive work — debugging only

```bash
salloc --partition=dev_gpu --gres=gpu:1 --time=00:30:00
srun --pty bash                      # a shell on a compute node
```

Always run `hostname` once you land, to confirm which node — and on multi-
generation sites, which cluster — you actually got.

## Moving data

```bash
rsync -avP file.tar.gz user@cluster:/path/to/destination/
rsync -avP --exclude='.git' mydir/ user@cluster:/path/mydir/
sha256sum file.tar.gz                # on both sides, compare
```

## Inside a job script

| Variable | Contains |
|---|---|
| `$SLURM_JOB_ID` | the job's ID |
| `$SLURM_SUBMIT_DIR` | where you ran `sbatch` |
| `$SLURM_ARRAY_TASK_ID` | this task's index, in an array job |
| `$SLURM_CPUS_PER_TASK` | cores allocated — use it to set thread counts |
| `$SLURM_JOB_NODELIST` | nodes assigned |

```bash
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-1}
```

Setting this stops BLAS libraries from spawning a thread per physical core and
oversubscribing your allocation.

---

Next: [When a job fails](07-debugging.md)

# 2. The batch job

A **job script** is an ordinary shell script with scheduler directives at the
top. Those directives are comments beginning `#SBATCH` — invisible to the
shell, read by Slurm when you submit.

```bash
#!/bin/bash
#SBATCH --job-name=my-run
#SBATCH --partition=gpu_h100
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=16
#SBATCH --time=04:00:00
#SBATCH --output=logs/run_%j.out

cd "$SLURM_SUBMIT_DIR"
module load devel/python/3.12.3-gnu-14.2
source .venv/bin/activate

python3 train.py --epochs 200
```

Submit it:

```bash
mkdir -p logs
sbatch myjob.sbatch
```

Slurm replies with a job ID and returns you to your prompt immediately.
**Nothing has run yet.**

## Why `cd "$SLURM_SUBMIT_DIR"` is the first line

Your job starts in your *home directory*, not where you submitted from. Slurm
sets `SLURM_SUBMIT_DIR` to the directory you ran `sbatch` in, so that line puts
you back where your code and data are.

Without it, every relative path in the script is wrong — including
`source .venv/bin/activate`, which then fails before anything else runs.

## Why `mkdir -p logs` matters

`%j` in the output path expands to the job ID, so concurrent jobs don't
overwrite each other's logs.

But Slurm opens that file **before** your script runs. If `logs/` doesn't
exist, the job dies instantly and writes the reason nowhere. This failure is
baffling the first time you hit it.

## The lifecycle

| State | Meaning |
|---|---|
| `PD` | **Pending** — waiting in line. The reason in parentheses says why. |
| `R` | **Running** — the `TIME` column counts up. |
| `CG` | **Completing** — cleaning up, usually seconds. |
| *(gone from `squeue`)* | Finished — successfully or not. Check with `sacct`. |

Common pending reasons:

- `(Priority)` — other jobs are ahead of you
- `(Resources)` — your request is valid, the hardware is busy
- `(None)` — Slurm hasn't finished scheduling yet, usually transient

None of these are errors.

## Jobs survive logout

This is the entire point of batch submission. Once `sbatch` accepts your job,
it runs on a compute node independently of your session. Close your laptop,
lose the VPN, get on a plane — it keeps going, and its output goes to the log
file.

Two things do **not** survive: `salloc` and `srun --pty` give you an
interactive allocation tied to your shell, and both die when you disconnect.
Use them for debugging, never for real runs.

## Job arrays

To run the same script over many inputs, don't submit a hundred jobs — submit
one array:

```bash
sbatch --array=0-19%5 myjob.sbatch
```

Twenty tasks, at most five running at once. Inside the script,
`$SLURM_ARRAY_TASK_ID` tells each task which slice it owns:

```bash
python3 process.py --chunk "$SLURM_ARRAY_TASK_ID"
```

This is the standard way to run a parameter sweep, and the throttle (`%5`)
keeps you from monopolising the queue.

---

Next: [Asking for resources](03-resources.md)

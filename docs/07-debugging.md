# 7. When a job fails

A job vanishing from `squeue` means it **left the queue** — not that it
succeeded. Always check.

```bash
sacct -j 12345 --format=JobID,State,Elapsed,MaxRSS,ExitCode
```

`COMPLETED` with exit code `0:0` is success. Anything else means reading the
logs:

```bash
tail -50 logs/myjob_12345.out
cat logs/myjob_12345.err
```

## Reading the state

| State / signal | Usual cause |
|---|---|
| `FAILED`, short `Elapsed` | Script error: bad path, missing module, venv not found |
| `TIMEOUT` | `--time` too short. Resubmit longer, ideally with checkpointing |
| `OUT_OF_MEMORY` | Exceeded `--mem`. Check `MaxRSS` and request more |
| `CANCELLED` | You, an administrator, or a failed dependency |
| `NODE_FAIL` | Hardware problem. Not your fault — resubmit |
| Exit `139` | Segmentation fault — compiled library, often architecture mismatch |
| Exit `137` | Killed by signal 9, usually the out-of-memory killer |
| Exit `127` | Command not found — module or venv missing |

## The failures you'll actually hit

### Dies in under a second

Almost always the environment: a missing `cd "$SLURM_SUBMIT_DIR"`, a module
that isn't loaded, or a venv path that doesn't resolve. The `.err` file names
it.

### "Requested node configuration is not available"

Your request can't be satisfied by any node in that partition. Usually `--mem`
on a partition that allocates memory per GPU, or more cores than a node has.

```bash
scontrol show partition <name>    # the real limits
```

### `torch.cuda.is_available()` is `False`

Three possibilities, in order of likelihood:

1. You forgot `--gres=gpu:1`
2. You're on a login node (which has no GPU)
3. You installed a CPU-only wheel

`nvidia-smi` inside the job distinguishes the first two from the third.

### The output file never appears

The directory named in `--output` didn't exist. Slurm opens that file *before*
your script runs, so the job dies with nothing written anywhere.

```bash
mkdir -p logs      # before submitting
```

### Works interactively, fails as a job

The canonical batch-job bug. Your interactive shell has modules loaded, a venv
active, and a working directory that the job does not inherit. Everything must
be in the script.

### Segmentation fault

See [the architecture trap](05-environments.md#the-architecture-trap). Check
`hostname`, and whether the node is the same generation as the one where you
built your environment.

## A habit worth forming

Put diagnostics at the top of every job script:

```bash
echo "job $SLURM_JOB_ID on $(hostname)  $(date)"
nvidia-smi --query-gpu=name --format=csv,noheader || true
python3 -c "import torch; print(torch.__version__, torch.cuda.is_available())"
```

Three lines, and the top of every log tells you which node, which GPU, and
whether the environment came up — before any question of whether your science
is right.

---

Next: [Good practice](08-good-practice.md)

# 8. Good practice

Habits that separate casual users from people who get work done on clusters.

## Always probe first

Before a twelve-hour job, run the same code for twenty minutes on a development
queue with a tiny input. It catches wrong partitions, broken environments,
missing files and bad paths for almost no cost.

A probe that fails in two minutes has saved you a day.

## Measure, then extrapolate

Time a small run, compute seconds per unit of work, multiply:

```
seconds per sample-epoch = wall_seconds / (n_samples × n_epochs)
full run                 = that × full_samples × full_epochs
```

This gives you a defensible `--time` instead of a guess, and tells you whether
the full job is affordable *before* you commit to it.

## Read the efficiency report

`sacct` reports what you actually used:

```bash
sacct -j 12345 --format=JobID,Elapsed,MaxRSS,AllocCPUS
```

A job showing 8% CPU efficiency on sixteen cores was waiting on something —
usually the data loader, sometimes the filesystem. That's a performance finding
sitting in your logs for free.

## Make jobs resumable

Write checkpoints. Have each stage skip itself if its output already exists:

```bash
if [[ -f "$OUT/result.json" ]]; then
    echo "SKIP $OUT (already done)"
    return 0
fi
```

A pipeline you can resubmit after a crash, and have it continue where it
stopped, is worth the hour it takes to write.

## Smallest first

When running a sweep, order it so partial results are still usable. Four
finished small runs are a figure; one half-finished large run is nothing.

## Record provenance

Git commit, hostname, library versions, date — written into the output file
itself, not a lab notebook:

```python
f.attrs["git_commit"] = subprocess.run(
    ["git", "rev-parse", "HEAD"], capture_output=True, text=True
).stdout.strip()
f.attrs["generated_utc"] = datetime.utcnow().isoformat()
f.attrs["numpy"] = np.__version__
```

Six months later, when a reviewer asks which version of the code produced a
dataset, `not-a-git-checkout` in your metadata is an answer you cannot give.

## Script everything, including the fixes

If you edited a file by hand on the cluster, that edit exists nowhere else. Put
it in a script, or in version control, or it will be lost the next time you
rebuild.

## Verify transfers

Compare `sha256sum` on both sides for anything large. A truncated HDF5 opens
without complaint and gives you wrong numbers silently — the worst possible
failure mode, because it looks like a result.

## Know which queue to use

Development queues are short-limit but nearly always available. Short queues
often start immediately via backfill. Reaching for the biggest partition by
reflex means waiting when you didn't need to.

## Be a good citizen

- No computation on login nodes
- Don't hold interactive allocations you aren't using
- Don't flood the queue with thousands of one-minute jobs — use arrays with a
  throttle
- Clean up scratch space you no longer need

Clusters are shared, and the person you inconvenience is usually in your own
department.

---

Next: [bwUniCluster 3.0 specifics](09-bwunicluster3.md)

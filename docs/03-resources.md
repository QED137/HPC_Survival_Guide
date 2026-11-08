# 3. Asking for resources

Five directives cover almost everything.

## `--partition`

Selects a queue. A partition is a named pool of nodes with its own hardware,
time limit and access rules. Choosing the wrong one is the most common
instant-rejection cause.

```bash
sinfo -s                             # list partitions and limits
scontrol show partition gpu_h100     # the details of one
```

## `--time`

A wall-clock limit, format `HH:MM:SS` or `D-HH:MM:SS`. When it expires your job
is **killed mid-computation** — no grace period, no checkpoint unless you wrote
one.

## `--cpus-per-task`

How many CPU cores you get. More cores help only if your code can use them. For
a GPU training job, cores matter mainly for the data loader — and a starved
data loader is a very common reason a GPU sits idle.

## `--mem`

Memory for the whole job (`--mem-per-cpu` is per core instead).

On many GPU partitions, memory is allocated automatically in proportion to the
GPUs you request. Passing `--mem` on top of that causes:

```
Requested node configuration is not available
```

Check your site's defaults with `scontrol show partition` before setting it.

## `--gres=gpu:1`

Requests a GPU.

> **Submitting to a GPU partition is not enough.** Without `--gres`, you get a
> node that has GPUs but your job may not touch them, and
> `torch.cuda.is_available()` returns `False`.

## The asymmetry to design around

Asking for **more** than you need costs you wait time — the scheduler must find
a window where all of it is free simultaneously.

Asking for **less** than you need costs you the entire job.

These are not equally bad. A job that waits two extra hours is an annoyance; a
job killed at hour eleven of twelve is a day lost. So: generous on `--time`,
realistic on everything else.

## Backfill, and why short jobs start sooner

Slurm reserves nodes for large pending jobs, then **backfills** the gaps with
shorter jobs that will finish before the reservation begins.

A job asking for one hour often starts immediately where a twelve-hour job
waits half a day. This is a real reason to split a long pipeline into stages
rather than submitting one monolithic job.

## Check before you commit

```bash
sbatch --test-only --partition=gpu_h100 --gres=gpu:1 \
       --time=04:00:00 --cpus-per-task=16 --wrap="hostname"
```

This **queues nothing**. It either reports an estimated start time or names the
exact resource it cannot satisfy. Use it to compare partitions before
committing a long job to a long queue.

---

Next: [Filesystems](04-filesystems.md)

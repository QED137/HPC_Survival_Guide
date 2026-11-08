# 1. What a cluster actually is

A cluster is not one big computer. It is a few hundred separate computers
(**nodes**) in a room, sharing a network and a filesystem, with a program
called a **scheduler** deciding who gets which node and when.

Three kinds of machine matter to you.

## Login nodes

What you get when you `ssh` in. There are only two or three, and every user on
the cluster shares them. They exist for editing files, submitting jobs, and
small housekeeping. They enforce strict per-user limits on memory and CPU time,
which is why a script that runs fine on your laptop can be killed abruptly here.

**Never run computation on a login node.** It is the most common beginner
mistake, it slows the machine for everyone, and administrators do notice.

## Compute nodes

Where work actually happens. Hundreds of them, each with many cores, large
memory, and sometimes GPUs. You cannot log into them directly. You *request*
one from the scheduler, and it grants you use of it for a bounded period.

## The shared filesystem

Every node sees the same files. This is why you can upload data on a login node
and read it from a compute node without copying anything.

## The scheduler is a queue, not a server

Here is the mental shift that matters: you are not running a program, you are
**filing a request that a program be run**. You state what you need — one GPU,
sixteen cores, four hours — and the scheduler puts you in line. When matching
resources free up, it starts your job, with no human involved and you possibly
asleep.

One consequence is worth internalising:

> Your job runs in an environment you never see interactively. It starts in a
> fresh shell, in your home directory, with no modules loaded and none of the
> environment you had when you submitted.

Everything the job needs must be stated inside the job script. Most beginner
failures are variants of *"it worked when I typed it, but the job didn't have
it."*

## Slurm

The scheduler on most academic clusters is **Slurm**. Every command in this
guide beginning with `s` belongs to it:

| Command | Purpose |
|---|---|
| `sbatch` | submit a job |
| `squeue` | see queued and running jobs |
| `sacct` | see finished jobs |
| `scancel` | cancel a job |
| `sinfo` | see partitions and nodes |
| `salloc` / `srun` | interactive allocation |

---

Next: [The batch job](02-batch-jobs.md)

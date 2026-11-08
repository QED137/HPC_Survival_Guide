# HPC Survival Guide

A practical introduction to using a Slurm HPC cluster, written for researchers
who were handed an account and a deadline rather than a training course.

It assumes you can use a terminal and have some reason to need a lot of compute.
It does not assume you know what a scheduler is.

Examples come from **bwUniCluster 3.0** (KIT, Germany), but almost everything
applies to any Slurm site. Site-specific material is confined to
[docs/09-bwunicluster3.md](docs/09-bwunicluster3.md).

## Contents

| | |
|---|---|
| 1 | [What a cluster actually is](docs/01-cluster-basics.md) — nodes, the scheduler, why you never compute on the login node |
| 2 | [The batch job](docs/02-batch-jobs.md) — job scripts, the lifecycle, why jobs survive logout |
| 3 | [Asking for resources](docs/03-resources.md) — partitions, time, cores, memory, GPUs |
| 4 | [Filesystems](docs/04-filesystems.md) — home, workspaces, scratch, and quotas that bite |
| 5 | [Software environments](docs/05-environments.md) — modules, virtualenvs, the architecture trap |
| 6 | [The commands worth knowing](docs/06-commands.md) — grouped by what you're trying to do |
| 7 | [When a job fails](docs/07-debugging.md) — exit codes and failure signatures |
| 8 | [Good practice](docs/08-good-practice.md) — habits that separate casual from professional use |
| 9 | [bwUniCluster 3.0](docs/09-bwunicluster3.md) — site specifics |

Plus a one-page [cheat sheet](CHEATSHEET.md) and runnable
[example job scripts](examples/).

## The five-minute version

If you read nothing else:

- **Never run computation on a login node.** Submit it with `sbatch`.
- **Your job does not inherit your shell.** Modules, virtualenv, working
  directory — all of it must be inside the job script.
- **`sbatch` returns immediately.** The job runs later, possibly much later,
  and survives you logging out.
- **Ask generously for time, realistically for everything else.** Running out
  of time kills the job; over-asking only makes you wait.
- **Probe before you commit.** Twenty minutes on a development queue catches
  almost every mistake that would otherwise waste twelve hours.

## Contributing

Corrections and site-specific additions are welcome. If something here is wrong
for your cluster, that is worth a pull request — the differences between sites
are exactly what makes this hard to learn.

## Licence

[CC BY 4.0](LICENSE). Use it for teaching, adapt it for your own site.

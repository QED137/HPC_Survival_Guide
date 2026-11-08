# 9. bwUniCluster 3.0

Site-specific notes for the KIT-hosted bwUniCluster 3.0. Everything else in
this guide is portable; this chapter is not.

> Verify against the [bwHPC wiki](https://wiki.bwhpc.de/) — sites change
> faster than documentation.

## Logging in

```bash
ssh tu_<your-id>@uc3.scc.kit.edu
```

Access is restricted to BelWü network addresses, so connect your university
VPN first if you're off campus. Authentication is a TOTP code followed by your
service password.

Username prefixes are per-institution: `tu_` for Tübingen, `ka_` for KIT, and
so on.

## Partitions

| Partition | Hardware | Max time |
|---|---|---|
| `cpu` | AMD, 96 cores/node | long |
| `cpu_il` | Intel Ice Lake, 64 cores | long |
| `highmem` | large-memory nodes | long |
| `gpu_h100` | 4× H100 per node | 72 h |
| `gpu_h100_il` | 4× H100, Ice Lake host | 72 h |
| `gpu_a100_il` | 4× A100 | 48 h |
| `gpu_mi300` | AMD MI300A — ROCm, not CUDA | — |
| `gpu_a100_short`, `gpu_h100_short` | same hardware | 30 min |
| `dev_cpu`, `dev_cpu_il`, `dev_gpu_h100`, `dev_gpu_a100_il` | development | 30 min |

GPU queues allocate memory and cores per GPU automatically:

- `gpu_h100` — 24 cores and ~193 GB per GPU
- `gpu_a100_il` — 16 cores and ~127 GB per GPU

**Do not pass `--mem`** on these. It causes "Requested node configuration is
not available".

Avoid `gpu_mi300` unless you have a ROCm build — a standard CUDA PyTorch wheel
will not run there.

## Site quirks

**`sinfo` is restricted** and returns `Access/permission denied`. Use the
wrapper instead:

```bash
sinfo_t_idle
```

**No accounts.** Omit `--account` entirely; submissions specifying one are
rejected.

## The UC2 trap

One login can reach nodes of both bwUniCluster **2.0** and **3.0**. These are
different hardware generations, and some partition names exist on both.

A virtualenv built on UC3 will **segfault** on a UC2 node. A job that lands on
the wrong generation dies the same way, after queueing for hours.

Always check after an interactive allocation:

```bash
hostname        # uc3n… good;  uc2n… wrong generation
```

Pin the cluster explicitly where a partition exists on both:

```bash
srun --clusters=uc3 --partition=dev_cpu_il --time=00:10:00 --pty bash
```

or in a job script:

```bash
#SBATCH --clusters=uc3
```

## Software

There is **no PyTorch module**. Load Python and build your own environment:

```bash
module load devel/python/3.12.3-gnu-14.2
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install torch --index-url https://download.pytorch.org/whl/cu124
```

Python 3.12 is the safe choice — 3.13 and 3.14 modules exist, but PyTorch
support for them is partial.

The pip wheel bundles its own CUDA runtime, so **do not** also load
`devel/cuda`. Mixing a system CUDA with a bundled one is a classic source of
confusing failures.

`devel/miniforge` is available if you prefer conda.

## Workspaces

```bash
ws_allocate myproject 60
cd $(ws_find myproject)
ws_list
ws_extend myproject 60
```

Home directories have a file-count quota that a single PyTorch install can eat
a large share of. Build environments and store datasets in a workspace.

## Documentation

- [bwHPC wiki](https://wiki.bwhpc.de/) — authoritative, with a dedicated
  bwUniCluster 3.0 section
- [SCC bwUniCluster page](https://www.scc.kit.edu/en/services/bwUniCluster.php)

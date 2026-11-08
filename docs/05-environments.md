# 5. Software environments

You cannot install system packages — no `sudo`, no `apt`. Clusters solve this
with **environment modules**: pre-built software you load into your shell on
demand.

```bash
module avail                        # everything available (long)
module avail 2>&1 | grep -i python  # filtered
module spider pytorch               # search, including hidden versions
module load devel/python/3.12.3-gnu-14.2
module list                         # what's loaded now
module purge                        # unload everything
```

Two things worth being clear about, because the names sound alarming:

- `module load` only edits environment variables — `PATH`,
  `LD_LIBRARY_PATH`, `PYTHONPATH`. It installs nothing.
- `module purge` only *unloads*. It deletes no files. Log out and back in and
  you are where you started.

**Loaded modules do not persist into your jobs.** Every job script must load
what it needs.

## Python environments

Most clusters provide Python but not scientific packages, so you build your
own:

```bash
module load devel/python/3.12.3-gnu-14.2
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

Three rules follow from how this works.

**Load the same module in every job that uses the venv.** A venv's `python3`
is a symlink into the interpreter you created it with. Purge or change that
module inside a job and the symlink points nowhere — the job dies in under a
second with a confusing "bad interpreter" error.

**Build the venv in a workspace, not `$HOME`.** File-count quota, as in
[chapter 4](04-filesystems.md).

**Install on a login node.** Compute nodes often have no outbound internet, so
`pip install` inside a job hangs or fails.

## Containers

Many sites support Apptainer (formerly Singularity), which gives you a
reproducible image instead of a hand-built environment:

```bash
apptainer pull docker://pytorch/pytorch:latest
apptainer exec --nv pytorch_latest.sif python3 train.py
```

`--nv` passes the GPU through. Worth learning if your dependencies are awkward
or you need the same environment on several machines.

## The architecture trap

This one is hard to diagnose and worth recognising on sight.

Compiled wheels — NumPy, SciPy, PyTorch — contain CPU instructions chosen when
the wheel was built or installed. A wheel installed on a node with AVX-512 can
crash on an older node that lacks those instructions:

```
Segmentation fault (core dumped)
```

No Python traceback. No error message. Just a dead process and exit code 139.

Two signatures:

- **Works on one node, segfaults on another** → architecture mismatch. Check
  `hostname` on both.
- **`import numpy` alone segfaults** → the install is broken or built for the
  wrong target. Rebuild the venv from scratch.

To see where it dies:

```bash
python3 -X faulthandler -c "import numpy"
```

If the stack ends inside a compiled extension's import, it's the binary, not
your code.

This matters especially where one login gives access to **two generations of
cluster**. A venv built on the new hardware will segfault on the old, and a job
that lands on the wrong generation dies the same way — after queueing for
hours.

---

Next: [The commands worth knowing](06-commands.md)

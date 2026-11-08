# 4. Filesystems

Clusters give you several filesystems with sharply different properties. Using
the wrong one is a slow-burning mistake: everything works until suddenly
nothing does.

## `$HOME`

Small, backed up, permanent. Source code, scripts, notes, small results.

Limited in total size **and in number of files**. The second limit catches
people out, because a single Python virtual environment contains tens of
thousands of small files and can exhaust it on its own.

## Workspaces / scratch

Large, fast, parallel, and **not backed up**. Datasets, checkpoints,
intermediate output, virtual environments.

On bwHPC sites these are *workspaces*, created with an expiry date:

```bash
ws_allocate myproject 60       # 60 days
ws_find myproject              # prints the path
ws_list                        # what you have, and when it expires
ws_extend myproject 60         # before it lapses — data is deleted after
```

`ws_find` printing a path is why you see this idiom:

```bash
cd $(ws_find myproject)
```

The `$( )` runs the inner command and substitutes its output.

Other sites call this `/scratch` or `/work` with a purge policy instead.

## Node-local `/tmp`

Fast, local to the compute node, **erased when your job ends**. Useful for
scratch files a single job writes and rereads heavily, where the shared
filesystem would be a bottleneck.

## The rule of thumb

- Small, and losing it would cost you a week → `$HOME`
- Large, and regenerable → workspace
- Large, and *not* regenerable → workspace **plus a real backup elsewhere**

"Not backed up" is meant literally. A failed disk or an expired workspace takes
everything with it.

## Check quota before large operations

```bash
lfs quota -uh $USER /path/to/filesystem   # Lustre
quota -s                                  # some sites
du -sh ~/some-directory                   # what a directory costs you
```

Running out of quota mid-job produces write errors that surface as confusing
application crashes, often far from the real cause. Check before extracting a
large archive or starting a run that writes checkpoints.

## Moving data in

```bash
# from your laptop, pushing up
rsync -avP data.tar.gz user@cluster:/path/to/destination/

# a directory, skipping things that shouldn't travel
rsync -avP --exclude='.git' --exclude='.venv' --exclude='__pycache__' \
      mydir/ user@cluster:/path/mydir/
```

Two rules that trip everyone:

**Run the transfer from the machine that has the file.** Whichever side you
type on, the *other* side gets the `user@host:` prefix. If you get
`link_stat ... No such file or directory` from the *sender*, you're running it
on the wrong machine.

**Verify large transfers.** A truncated HDF5 or archive often opens without
complaint and gives wrong results silently:

```bash
sha256sum data.tar.gz      # run on both sides, compare
```

`-P` resumes an interrupted transfer if you rerun the identical command.

---

Next: [Software environments](05-environments.md)

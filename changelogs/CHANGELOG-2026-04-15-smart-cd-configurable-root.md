# Changelog: Smart cd — Configurable Search Root

**Date:** 2026-04-15
**Classification:** [setup]

## Goal

The smart-cd wrapper originally hard-coded its search root to `~/source`. That directory does not exist on every machine, so on a fresh setup `cd` / `cd <query>` returned an empty picker (`0/0`).

Make the root configurable via a `SMART_CD_ROOT` variable. On new-machine setup, ask the user where their code/projects live and set it accordingly.

## Change

Introduce `SMART_CD_ROOT` at the top of the smart-cd block in `~/.bashrc`. All three references inside `__smart_cd_pick` (`fd` target, `sed` strip prefix, final `builtin cd` path) use the variable.

```bash
SMART_CD_ROOT="$HOME/source"   # edit per machine
```

Examples of per-machine values:

- `$HOME/source` — the original default
- `/mnt/d` — WSL machine with code on the D: drive (this machine)
- `/mnt/c/dev`, `/workspace`, etc.

## Setup-Guide Workflow

SETUP-GUIDE.md now instructs the agent to **ask the user** for the correct root when walking through the shell block on a new machine. The default line is left as `$HOME/source` with an `<-- edit per machine` comment so it is impossible to miss.

## Verification

On this machine (`/mnt/d`):

```bash
source ~/.bashrc
cd ho       # picker opens, fuzzy-matches housekeeping etc.
cd          # picker opens with full list under /mnt/d
cd /tmp     # builtin cd, no picker
```

## Notes

- No behavior change when `SMART_CD_ROOT` equals `$HOME/source` — backward compatible with the original changelog.
- Still guarded by the `fzf` + `fd`/`fdfind` check, so missing tools silently disable the override.

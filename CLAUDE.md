# CLAUDE.md

> `AGENTS.md` mirrors this file for compatibility with non-Claude AI coding harnesses. Keep both files in sync. This file is the primary source of truth.

## Purpose

This repo stores the shared WezTerm + terminal setup and the documentation to reproduce it on any machine. It is used across multiple systems via git. Keep instructions portable, explicit, and easy for a new session agent to continue.

## File Structure

```
CLAUDE.md              — primary agent instructions (this file)
AGENTS.md              — mirror of CLAUDE.md for other AI harnesses
SETUP-GUIDE.md         — baseline setup, runnable end to end on a new machine
CHANGELOG-SUMMARY.md   — index of all changes with [setup]/[optional] tags
changelogs/            — one file per change, named CHANGELOG-DATE-title.md
.changelog-status      — local per-machine list of applied changelogs (git-ignored)
```

## How Setup and Changelogs Work Together

Think of this as event sourcing:

- **SETUP-GUIDE.md** is the **snapshot** — the accumulated baseline. Running it on a fresh machine produces a fully working setup.
- **Changelogs** are **events** — each one records a single change with enough detail to reproduce it.
- **CHANGELOG-SUMMARY.md** is the **index** — lists every changelog with a tag and a link.

### Tags

- **`[setup]`** — this change is already folded into SETUP-GUIDE.md. The changelog file exists for historical record. No need to apply it separately.
- **`[optional]`** — this change is NOT in the setup guide. When setting up a new machine, present it to the user for a yes/no decision.

### Workflow: making a change

1. Make the change in the live config.
2. Create a changelog file in `changelogs/` named `CHANGELOG-YYYY-MM-DD-descriptive-title.md`.
3. Classify the change as `[setup]` or `[optional]`:
   - **Communicate the classification to the user** with a brief reason. Example: *"I'm classifying this as [setup] because it improves the experience on any machine"* or *"I'm classifying this as [optional] because it depends on a tool that may not be on every machine."*
   - **The user may override the classification.** If they do, update accordingly.
4. If `[setup]`: also update SETUP-GUIDE.md to include the change.
5. Add the entry to CHANGELOG-SUMMARY.md with the tag and a link to the changelog file.
6. Add the changelog filename (no path) to `.changelog-status` on this machine — it was just applied here.

### Workflow: setting up a new machine

1. Run SETUP-GUIDE.md end to end. This covers everything tagged `[setup]`.
2. Initialize `.changelog-status` — add all changelogs currently tagged `[setup]` in CHANGELOG-SUMMARY.md. They are already folded into the setup guide so there is nothing to apply; the file just records that they are done.
3. Read CHANGELOG-SUMMARY.md, filter to `[optional]` entries only.
4. Present each one to the user with its description. User says yes or no.
5. For each yes, read the linked changelog file, apply the change, and add the filename to `.changelog-status`.

### Workflow: syncing an existing machine

Run this when a machine already has a `.changelog-status` and you want to bring it up to date.

1. Read `.changelog-status` to get the list of already-applied changelogs.
2. Read CHANGELOG-SUMMARY.md top to bottom (chronological order).
3. Identify every changelog filename not present in `.changelog-status`.
4. For each missing entry in order:
   - `[setup]`: read the changelog file, apply the change, add filename to `.changelog-status`.
   - `[optional]`: present the description to the user (yes/no). If yes, apply and add to `.changelog-status`. If no, skip — do not add, so the user will be asked again on the next sync.
5. When there are no more missing entries, the machine is up to date.

## Config Paths

These are machine-relative. The Windows username and WSL distro name will differ per system.

- WezTerm config: `/mnt/c/Users/<USERNAME>/.wezterm.lua`
- Oh My Posh theme: `~/.config/oh-my-posh/theme.omp.json`
- Bash shell config: `~/.bashrc`

## Changelog File Requirements

Each changelog file records a single change:

- What the user was trying to achieve.
- The commands that were run.
- The configuration values that were added, changed, or validated.
- Notable iterations, fixes, and things to watch out for.
- Enough detail that the same change can be reproduced on a different system.

## Summary File Requirements

- One line per change: tag, description, link.
- Keep entries in chronological order.
- Do not remove entries — the summary is the complete index.

## Style

- Be concise.
- Avoid stating obvious things.
- Prefer practical instructions over commentary.
- Keep docs skimmable in raw Markdown.
- Use explicit paths, commands, and config values.

## Config Editing Guidance

- Preserve the existing structure and style of the config you are editing.
- Keep related WezTerm settings grouped together.
- Use clear names for extracted variables or helper functions.
- Document platform-specific assumptions when they matter.

## Validation

- Work with the user to verify that changes behave as expected.
- Note the verification steps and observed result in the changelog file.

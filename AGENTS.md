# AGENTS.md

> This file mirrors `CLAUDE.md` for compatibility with non-Claude AI coding harnesses. Keep both files in sync. `CLAUDE.md` is the primary source of truth.

## Purpose

This repo stores the shared WezTerm + terminal setup and the documentation to reproduce it on any machine. It is used across multiple systems via git. Keep instructions portable, explicit, and easy for a new session agent to continue.

## File Structure

```
CLAUDE.md              — primary agent instructions
AGENTS.md              — mirror of CLAUDE.md for other AI harnesses (this file)
SETUP-GUIDE.md         — baseline setup, runnable end to end on a new machine
CHANGELOG-SUMMARY.md   — index of all changes with [setup]/[optional] tags
changelogs/            — one file per change, named CHANGELOG-DATE-title.md
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

### Workflow: setting up a new machine

1. Run SETUP-GUIDE.md end to end. This covers everything tagged `[setup]`.
2. Read CHANGELOG-SUMMARY.md.
3. Filter to `[optional]` entries only.
4. Present each one to the user with its description. User says yes or no.
5. For each yes, read the linked changelog file and apply the change.

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

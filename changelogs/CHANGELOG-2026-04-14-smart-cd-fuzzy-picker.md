# Changelog: Smart cd — Fuzzy Interactive Directory Picker

**Date:** 2026-04-14
**Classification:** [setup]

## Goal

Replace the default `cd` command in bash with a smart wrapper that:
- With no arguments, opens a fuzzy directory picker across `~/source`
- With an existing path, behaves like normal `cd`
- With an unknown string (non-existent path), opens the picker pre-filtered with that query

## Packages Required

```bash
sudo apt-get install -y fzf fd-find
```

`fdfind` is the binary name for `fd-find` on Debian/Ubuntu. The wrapper checks for both `fd` and `fdfind` automatically.

## .bashrc Block

Add at the end of `~/.bashrc`, after the Oh My Posh init line:

```bash
# smart-cd: fuzzy interactive directory picker (interactive shells only)
if command -v fzf >/dev/null 2>&1 && { command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1; }; then

  __smart_cd_pick() {
    local FD target
    FD=$(command -v fd || command -v fdfind) || return 1
    target=$(
      "$FD" . "$HOME/source" \
        --type d --max-depth 5 --hidden \
        --exclude .git --exclude node_modules --exclude bin --exclude obj \
        --exclude .cache --exclude .local --exclude .npm --exclude .cargo \
        --exclude .venv --exclude venv --exclude dist --exclude build \
        --exclude target --exclude Downloads --exclude Pictures \
        --exclude Videos --exclude Music \
        2>/dev/null |
      sed "s|^$HOME/source/||" |
      fzf --height 50% --reverse --prompt="cd> " --query="${*:-}"
    )
    [ -n "$target" ] && builtin cd "$HOME/source/$target"
  }

  cd() {
    if [[ $- != *i* ]]; then
      builtin cd "$@"
      return
    fi

    if [ $# -eq 0 ]; then
      __smart_cd_pick
      return
    fi

    if [ -d "$1" ] || [ -f "$1" ] || [[ "$1" == .* ]] || [[ "$1" == /* ]] || [[ "$1" == ~* ]]; then
      builtin cd "$@"
      return
    fi

    __smart_cd_pick "$*"
  }

fi
# end smart-cd
```

## Notable Iterations

- `--ignore-case` flag does not exist in fzf 0.44 (Debian package). Removed. fzf's default smart-case already handles lowercase queries case-insensitively.
- Initial attempt computed last-3-path-fragments via a python3 subprocess per line and buffered through `sort`. With 1970+ directories this was visibly slow. Replaced with a direct `fdfind | sed | fzf` pipeline — results stream into fzf immediately.
- Search root narrowed from `$HOME` to `~/source` to reduce noise and improve speed.

## Verification

```bash
source ~/.bashrc
cd               # opens fzf picker showing dirs under ~/source
cd liceapi       # opens picker with "liceapi" pre-typed, fuzzy-matches licenseprovisioning.api
cd ~/some/path   # behaves like normal cd — no picker
cd ..            # behaves like normal cd — no picker
cd /tmp          # behaves like normal cd — no picker
```

## Safety

- The entire `cd` override is wrapped in a guard that checks for both `fzf` and `fd`/`fdfind`. If either tool is missing the wrapper is silently skipped and `cd` behaves normally.
- `[[ $- != *i* ]]` ensures the override only applies in interactive shells. Scripts and non-interactive shells hit `builtin cd` directly.

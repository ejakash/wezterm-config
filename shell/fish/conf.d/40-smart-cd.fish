# smart-cd fallback root. The real per-machine value is set in 00-machine.fish
# (from machine.sample.fish); this only catches a missing machine file.
set -q SMART_CD_ROOT; or set -gx SMART_CD_ROOT $HOME

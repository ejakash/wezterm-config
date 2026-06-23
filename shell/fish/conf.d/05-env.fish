# Load personal environment variables from ~/.bash_env so the same file works
# in both bash and fish. We run bash twice and diff its env: baseline first,
# then after sourcing the file. Anything new or changed gets `set -gx`'d here.
# This handles arbitrary bash syntax (export, quoting, $VAR expansion, command
# substitution) without parsing bash ourselves.
if test -f $HOME/.bash_env
    set -l baseline (bash --noprofile --norc -c 'env -0' | string split0)
    set -l loaded (bash --noprofile --norc -c 'set -a; source ~/.bash_env >/dev/null 2>&1; env -0' | string split0)

    for entry in $loaded
        # Skip unchanged entries
        contains -- $entry $baseline; and continue

        set -l kv (string split -m 1 = -- $entry)
        test (count $kv) -eq 2; or continue
        set -l key $kv[1]
        set -l val $kv[2]

        # Don't clobber shell-managed vars
        contains -- $key PATH PWD OLDPWD SHLVL _ SHELL; and continue

        set -gx $key $val
    end
end

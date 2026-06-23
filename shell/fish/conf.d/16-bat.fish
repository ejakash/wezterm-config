# Ubuntu installs bat as `batcat` to avoid a name clash. Alias back to `bat`.
# Intentionally NOT aliasing `cat` — scripts and piped use rely on plain cat.
if type -q batcat
    alias bat='batcat'
end

# Smart ls via eza
if type -q eza
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -la --icons --group-directories-first --git'
    alias la='eza -a --icons --group-directories-first'
    alias l='eza --icons --group-directories-first'
    alias lt='eza --tree --icons --level=2'
else
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
end

# Coloured grep (fish defaults aren't coloured)
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Windows .NET from WSL
alias dotnet='dotnet.exe'

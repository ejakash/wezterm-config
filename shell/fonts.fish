#!/usr/bin/env fish
# Download the font registry's binaries into the gitignored fonts/assets/
# (WezTerm's font_dirs target). Idempotent — re-run anytime. All fonts here are
# free (OFL / open). Adding a font: add fonts/<name>.lua + a line below, re-run.
# JetBrains Mono is installed on the Windows side, so it has no entry.
set -l repo (dirname (dirname (realpath (status filename))))
set -l assets $repo/fonts/assets
set -l tmp (mktemp -d)
mkdir -p $assets

function _zip -a subdir url files
    set -l z $tmp/(basename $url)
    if not test -f $z
        echo "  fetch "(basename $url)
        curl -fsSL -o $z $url; or begin; echo "    FAILED: $url" >&2; return 1; end
    end
    mkdir -p $assets/$subdir
    unzip -j -o $z (string split ' ' $files) -d $assets/$subdir >/dev/null 2>&1
    echo "  $subdir ok"
end

function _raw -a subdir urls
    mkdir -p $assets/$subdir
    for u in (string split ' ' $urls)
        curl -fsSL -o $assets/$subdir/(basename $u) $u; or echo "    FAILED: $u" >&2
    end
    echo "  $subdir ok"
end

set -l NF https://github.com/ryanoasis/nerd-fonts/releases/latest/download
set -l SM https://raw.githubusercontent.com/internet-development/www-server-mono/main/public/fonts

_zip maple      https://github.com/subframe7536/maple-font/releases/download/v7.9/MapleMono-NF.zip \
    "MapleMono-NF-Regular.ttf MapleMono-NF-Bold.ttf MapleMono-NF-Italic.ttf MapleMono-NF-BoldItalic.ttf"
_zip plex       $NF/IBMPlexMono.zip \
    "BlexMonoNerdFont-Regular.ttf BlexMonoNerdFont-Bold.ttf BlexMonoNerdFont-Italic.ttf BlexMonoNerdFont-BoldItalic.ttf"
_zip ioskeley   https://github.com/ahatem/IoskeleyMono/releases/download/v2.0.0/IoskeleyMono-NerdFont.zip \
    "Normal/IoskeleyMonoNerdFont-Regular.ttf Normal/IoskeleyMonoNerdFont-Bold.ttf Normal/IoskeleyMonoNerdFont-Italic.ttf Normal/IoskeleyMonoNerdFont-BoldItalic.ttf"
_raw server     "$SM/ServerMono-Regular.otf $SM/ServerMono-RegularOblique.otf"
_zip mona-neon  $NF/Monaspace.zip "MonaspiceNeNerdFont-Regular.otf MonaspiceNeNerdFont-Bold.otf MonaspiceNeNerdFont-Italic.otf"
_zip mona-argon $NF/Monaspace.zip "MonaspiceArNerdFont-Regular.otf MonaspiceArNerdFont-Bold.otf MonaspiceArNerdFont-Italic.otf"
_zip mona-xenon $NF/Monaspace.zip "MonaspiceXeNerdFont-Regular.otf MonaspiceXeNerdFont-Bold.otf MonaspiceXeNerdFont-Italic.otf"
_zip commit     $NF/CommitMono.zip "CommitMonoNerdFont-Regular.otf CommitMonoNerdFont-Bold.otf CommitMonoNerdFont-Italic.otf"
_zip geist      $NF/GeistMono.zip "GeistMonoNerdFont-Regular.otf GeistMonoNerdFont-Bold.otf GeistMonoNerdFont-Italic.otf"

rm -rf $tmp
echo "done -> $assets"

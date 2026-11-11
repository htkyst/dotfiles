#!/bin/sh
set -eu
cd "$(dirname "$0")"

# Arch: pacman -S qt6-shadertools
if [ -n "${QSB:-}" ]; then
    compiler=$QSB
elif command -v qsb >/dev/null 2>&1; then
    compiler=qsb
elif command -v qsb6 >/dev/null 2>&1; then
    compiler=qsb6
elif [ -x /usr/lib/qt6/bin/qsb ]; then
    compiler=/usr/lib/qt6/bin/qsb
else
    echo 'qsb が見つかりません。qt6-shadertools をインストールするか QSB を指定してください。' >&2
    exit 1
fi

"$compiler" --glsl '100 es,120,150' --hlsl 50 --msl 12 \
    -o shaders/page.frag.qsb shaders/page.frag

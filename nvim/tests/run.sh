#!/usr/bin/env bash
# init.lua'yi gecici XDG dizinlerinde (gercek ~/.config'e dokunmadan) taze kurar ve check.lua'yi kosar.
# Ag gerekir (eklentiler GitHub'dan indirilir). Kullanim: bash nvim/tests/run.sh
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
NVIM_DIR="$(dirname "$SCRIPT_DIR")"

tmp="$(mktemp -d)"
trap 'rm -rf -- "${tmp:?}"' EXIT

export XDG_CONFIG_HOME="$tmp/config" XDG_DATA_HOME="$tmp/data" \
       XDG_STATE_HOME="$tmp/state" XDG_CACHE_HOME="$tmp/cache"
mkdir -p "$XDG_CONFIG_HOME/nvim"
cp "$NVIM_DIR/init.lua" "$XDG_CONFIG_HOME/nvim/init.lua"

echo "==> eklentiler taze kuruluyor (gecici dizin: $tmp)"
nvim --headless "+Lazy! sync" "+qa!" >/dev/null 2>&1 || true

echo "==> kontroller"
timeout 600 nvim --headless "+luafile $SCRIPT_DIR/check.lua"

#!/usr/bin/env bash
# init.lua'yi gecici XDG dizinlerinde (gercek ~/.config'e dokunmadan) taze kurar ve check.lua'yi kosar.
# Ag gerekir (eklentiler GitHub'dan indirilir). Kullanim: bash nvim/tests/run.sh
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
NVIM_DIR="$(dirname "$SCRIPT_DIR")"

tmp="$(mktemp -d)"
# Temizlik hatasi (kapanan sureclerle yaris) testin sonucunu bozmasin
trap 'rm -rf -- "${tmp:?}" 2>/dev/null || true' EXIT

# HOME de gecici olmali: bazi eklentilerin kurulum adimi $HOME'a yazar (fzf eklentisi ~/.fzf.bash'i gecici
# yolla yeniden yazip gercek kabugu bozmustu). Git ayari (proxy, CA) gercek HOME'dan okunmaya devam eder.
[ -f "$HOME/.gitconfig" ] && export GIT_CONFIG_GLOBAL="$HOME/.gitconfig"
mkdir -p "$tmp/home"; export HOME="$tmp/home"
export XDG_CONFIG_HOME="$tmp/config" XDG_DATA_HOME="$tmp/data" \
       XDG_STATE_HOME="$tmp/state" XDG_CACHE_HOME="$tmp/cache"
mkdir -p "$XDG_CONFIG_HOME/nvim"
cp "$NVIM_DIR/init.lua" "$XDG_CONFIG_HOME/nvim/init.lua"
cp -r "$NVIM_DIR/lua" "$XDG_CONFIG_HOME/nvim/lua"

echo "==> eklentiler taze kuruluyor (gecici dizin: $tmp)"
nvim --headless "+Lazy! sync" "+qa!" >/dev/null 2>&1 || true

echo "==> kontroller"
timeout 600 nvim --headless "+luafile $SCRIPT_DIR/check.lua"

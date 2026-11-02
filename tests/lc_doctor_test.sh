#!/usr/bin/env bash
# bin/lc-doctor testi: gecici HOME ile (gercek makineye dokunmaz).
# shellcheck disable=SC2088  # ~ in messages is literal text, not a path to expand
set -Eeuo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "${tmp:?}" 2>/dev/null || true' EXIT

failed=0
ok() { local msg="$1"; shift; if "$@"; then echo "PASS $msg"; else echo "FAIL $msg"; failed=$((failed + 1)); fi; }
not() { ! "$@"; }
has() { grep -qF -- "$2" <<<"$1"; }

D="$REPO/bin/lc-doctor"
export HOME="$tmp/home"; mkdir -p "$HOME"
run() { "$D" "$@" 2>&1 || true; }

out="$(run)"
ok "bos HOME: bagi olmayan dosyalar MISS" has "$out" "MISS $HOME/.bashrc missing"
ok "bos HOME: cikis kodu 1" not "$D" >/dev/null 2>&1
ok "bos HOME: duzeltme ipucu var" has "$out" "-> ./install.sh"
ok "-q yalniz sorunlari basar" test -z "$(run -q | grep '^ok' || true)"
ok "-h kullanimi gosterir" has "$("$D" -h)" "full report"
ok "bilinmeyen secenek hata verir" not "$D" --nope

# bagli dosyalar kurulunca bag MISS'leri kaybolur
mkdir -p "$HOME/.config/nvim" "$HOME/.local/bin"
ln -s "$REPO/bash/.bashrc" "$HOME/.bashrc"
ln -s "$REPO/tmux/.tmux.conf" "$HOME/.tmux.conf"
ln -s "$REPO/nvim/init.lua" "$HOME/.config/nvim/init.lua"
ln -s "$REPO/nvim/lua" "$HOME/.config/nvim/lua"
for b in lc-help lc-doctor lc-issue-hook; do ln -s "$REPO/bin/$b" "$HOME/.local/bin/$b"; done
cp "$REPO/git/.gitconfig" "$HOME/.gitconfig"
out="$(run)"
ok "baglar kurulunca bag MISS'i yok" not has "$out" "is not a link"
ok "baglar kurulunca eksik bag yok" not has "$out" "$HOME/.bashrc missing"
ok "gitconfig ayniysa uyari yok" not has "$out" "~/.gitconfig differs"
echo "# fark" >> "$HOME/.gitconfig"
ok "gitconfig farkliysa uyarir" has "$(run)" "~/.gitconfig differs"

# yanlis hedefe giden bag yakalanir
rm "$HOME/.tmux.conf"; ln -s "$REPO/README.md" "$HOME/.tmux.conf"
ok "yanlis hedefli bag MISS" has "$(run)" "$HOME/.tmux.conf exists but is not a link"

# tum zorunlu programlar PATH'teyse temiz depoda cikis kodu 0 (degilse atla)
missing_prog=""
for c in git tmux nvim fzf python3; do command -v "$c" >/dev/null 2>&1 || missing_prog="$missing_prog $c"; done
if [ -z "$missing_prog" ]; then
    rm "$HOME/.tmux.conf"; ln -s "$REPO/tmux/.tmux.conf" "$HOME/.tmux.conf"
    ok "her sey bagliyken cikis kodu 0" "$D" >/dev/null 2>&1
else
    echo "SKIP cikis kodu 0 testi (eksik program:$missing_prog)"
fi

# help/tools.tsv'deki her arac paket->komut tablosunda
nomap=""
for n in $(awk -F'\t' '!/^#/ && NF >= 2 && $4 != "usage" { print $1 }' "$REPO/help/tools.tsv" | sort -u); do
    grep -qF "[$n]=" "$D" || nomap="$nomap $n"
done
ok "tools.tsv'deki her arac lc-doctor komut tablosunda${nomap:+ (eksik:$nomap)}" test -z "$nomap"

echo
if [ "$failed" -eq 0 ]; then echo "TUMU GECTI"; else echo "$failed KONTROL BASARISIZ"; exit 1; fi

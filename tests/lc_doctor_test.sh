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
# install-tools.sh git'e delta include'unu ekler: bu bir "fark" sayilmaz
printf '[include]\n\tpath = ~/.gitconfig.delta\n' >> "$HOME/.gitconfig"
ok "yalniz delta include'u eklenmisse uyari yok" not has "$(run)" "~/.gitconfig differs"
echo "# fark" >> "$HOME/.gitconfig"
ok "gitconfig farkliysa uyarir" has "$(run)" "~/.gitconfig differs"
cp "$REPO/git/.gitconfig" "$HOME/.gitconfig"

# git alt komutu olan araclar (git-absorb) PATH'te degil git'in exec-path'indedir: kurulu sayilmali
mkdir -p "$tmp/gx-empty" "$tmp/gx"; printf '#!/bin/sh\n' > "$tmp/gx/git-absorb"; chmod +x "$tmp/gx/git-absorb"
if ! command -v git-absorb >/dev/null 2>&1; then
    n_without="$(GIT_EXEC_PATH="$tmp/gx-empty" "$D" 2>&1 | sed -n 's/^ok   \([0-9]*\) tools installed/\1/p')"
    n_with="$(GIT_EXEC_PATH="$tmp/gx" "$D" 2>&1 | sed -n 's/^ok   \([0-9]*\) tools installed/\1/p')"
    ok "git-absorb git exec-path'indeyse kurulu sayilir" test "$((n_with - n_without))" -eq 1
else
    echo "SKIP git-absorb PATH'te; exec-path testi anlamsiz"
fi

# /tmp'e giden ~/.fzf.bash yakalanir
printf 'PATH="$PATH:/tmp/tmp.x/data/nvim/lazy/fzf/bin"\n' > "$HOME/.fzf.bash"
ok "~/.fzf.bash olmayan dizine isaret ediyorsa MISS" has "$(run)" "MISS ~/.fzf.bash points to a missing directory"
mkdir -p "$HOME/.fzf/bin"
printf 'PATH="$PATH:%s/.fzf/bin"\n' "$HOME" > "$HOME/.fzf.bash"
ok "~/.fzf.bash saglamsa uyari yok" not has "$(run)" "points to a missing directory"
rm -f "$HOME/.fzf.bash"

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

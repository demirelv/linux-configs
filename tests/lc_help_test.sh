#!/usr/bin/env bash
# bin/lc-help testi: indeks kaynaklarla uyumlu mu, arama, bayat indeks, Ingilizce-only, fzf yolu (gercek pty).
set -Eeuo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "${tmp:?}" 2>/dev/null || true' EXIT

failed=0
ok() { local msg="$1"; shift; if "$@"; then echo "PASS $msg"; else echo "FAIL $msg"; failed=$((failed + 1)); fi; }
not() { ! "$@"; }
has() { grep -qF -- "$2" <<<"$1"; }

export LC_HELP_CACHE="$tmp/cache"
L="$REPO/bin/lc-help"
"$L" --rebuild >/dev/null
IDX="$LC_HELP_CACHE/index.tsv"
count() { awk -F'\t' -v k="$1" '$1 == k' "$IDX" | wc -l; }

# 1) her tur dolu; ikiden fazla kaynak tek yerde birlesir
ok "indekste komut girdileri var" test "$(count cmd)" -ge 9
ok "indekste ortam degiskeni girdileri var" test "$(count env)" -ge 3
ok "indekste tmux kisayollari var (varsayilan + bizimkiler)" test "$(count tmux)" -ge 60
if command -v nvim >/dev/null 2>&1 && [ -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]; then
    ok "indekste Neovim kisayollari var" test "$(count nvim)" -ge 50
else
    echo "SKIP Neovim girdileri (nvim ya da eklentileri kurulu degil)"
fi

# 2) kullaniciya donuk her .bashrc fonksiyonunun bir '# help:' girdisi var
missing=""
for fn in $(grep -oE '^[a-z][a-z0-9_-]*\(\)' "$REPO/bash/.bashrc" | tr -d '()' | sort -u); do
    awk -F'\t' -v f="$fn" '$1 == "cmd" { split($2, a, " "); if (a[1] == f) found = 1 } END { exit !found }' "$IDX" || missing="$missing $fn"
done
ok "her .bashrc fonksiyonunun help girdisi var${missing:+ (eksik:$missing)}" test -z "$missing"

# 3) tmux.conf'taki her bind -N notlu (aksi halde Prefix ? ve lc-help'te gorunmez)
nonote="$(grep -nE '^(bind|bind-key)[[:space:]]' "$REPO/tmux/.tmux.conf" | grep -v -- ' -N ' | cut -c1-70 || true)"
ok "tmux.conf'taki her bind-key -N notu tasiyor${nonote:+ (notsuz: $nonote)}" test -z "$nonote"

# 4) help/tools.tsv ile install-tools.sh paket listeleri ayni
pk="$(grep -E '^\s+\[[a-z0-9-]+\]="' "$REPO/tools/install-tools.sh" | sed -E 's/^[^"]*"//; s/".*$//' | tr ' ' '\n' | sort -u)"
tl="$(awk -F'\t' '!/^#/ && NF >= 2 && $4 != "extra" && $4 != "usage" { print $1 }' "$REPO/help/tools.tsv" | sort -u)"
ok "help/tools.tsv ile install-tools.sh ayni paketleri listeler" test "$pk" = "$tl"

# 5) Ingilizce-only: ASCII disi karakter ve Turkce ASCII kelimeler yok
ok "indekste ASCII disi karakter yok" not grep -qaP '[^\x00-\x7F]' "$IDX"
# 'yardim' satiri muaf: komutun kendi adi ve 'ara' alt komutu Turkce sozcuktur, aciklamasi Ingilizcedir
ok "indekste Turkce kelime yok" not bash -c 'grep -av "^cmd.yardim" "$1" | grep -qaiwE "dosya|dosyayi|oturum|kisayol|icin|bicimlendir|degistir|kapat|secim|secili|satir|sekme|komut|ara|goster"' _ "$IDX"

# 6) arama ve gorunumler (terminal degil -> duz liste)
ok "kelime ile arama: tmj -> komut" has "$("$L" tmj)" "Join a window"
ok "buyuk/kucuk harf duyarsiz" has "$("$L" TMJ)" "tmj"
ok "tur filtresi: tmux reload -> Prefix r" has "$("$L" tmux reload)" "Prefix r"
ok "tur filtresi yalniz o turu verir" not bash -c '"$1" tmux | grep -q "^cmd"' _ "$L"
ok "-k yalniz tmux ve nvim verir" not bash -c '"$1" -k | grep -qE "^(cmd|tool|env)"' _ "$L"
ok "birden cok kelime hepsi eslesmeli" test "$("$L" tool serial reconnect | wc -l)" -eq 1
ok "apt-disi (extra) arac de bulunur" has "$("$L" tool starship)" "starship"
ok "usage satirlari: her birinde ornek komut var" test -z "$(awk -F'\t' '$4 == "usage" && $3 == "" { print $1 }' "$REPO/help/tools.tsv")"
ok "usage ornegi aranabilir: rg -t" has "$("$L" tool rg type)" "Only one file type"
ok "extra arac kaynagi docs/araclar.md" grep -qP "^tool\tstarship\t.*\tdocs/araclar.md" "$LC_HELP_CACHE/index.tsv"
ok "--list tum turleri sayar" has "$("$L" --list)" "tmux"
ok "eslesme yoksa cikis kodu 1" not "$L" zzzz-hic-yok
ok "eslesme yokken stderr'e mesaj yazar" has "$("$L" zzzz-hic-yok 2>&1 || true)" "no match"
ok "--preview-line alanlari yazar" has "$("$L" --preview-line $'tool\tbear\tDescribes bear\tsrc\tbear -- make')" "Example:  bear -- make"
ok "-h kullanimi gosterir" has "$("$L" -h)" "fuzzy search"

# 7) kaynak degisince indeks yeniden uretilir
before="$(stat -c %Y "$IDX")"
sleep 1; touch "$REPO/help/tools.tsv"
"$L" --list >/dev/null
after="$(stat -c %Y "$IDX")"
ok "kaynak degisince indeks otomatik yenilenir" test "$after" -gt "$before"

# 8) fzf yolu: gercek bir pty icinde (tek eslesme otomatik secilir, onizleme basilir)
if command -v fzf >/dev/null 2>&1 && command -v script >/dev/null 2>&1; then
    out="$(FZF_DEFAULT_OPTS='--exact --select-1 --exit-0' script -qec "$L tmj" /dev/null 2>&1 | tr -d '\r' | sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g')"
    ok "fzf (pty): secilen girdinin ayrintisi yazilir" has "$out" "Key:      tmj [session:window] [target]"
else
    echo "SKIP fzf yolu (fzf ya da script yok)"
fi

echo
if [ "$failed" -eq 0 ]; then echo "TUMU GECTI"; else echo "$failed KONTROL BASARISIZ"; exit 1; fi

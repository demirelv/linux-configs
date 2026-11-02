#!/usr/bin/env bash
# Tek komutla tum kontroller: sozdizimi, shellcheck, kabuk, tmux eklenti ve nvim testleri.
# Kullanim:
#   ./check.sh          # hepsi (nvim testi eklentileri indirir, ag gerekir)
#   ./check.sh --fast   # ag gerektiren testleri (tmux eklentileri, nvim) atla
# Baska bir yerdeki ikili icin: SHELLCHECK=/yol/shellcheck ./check.sh
set -Eeuo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd -- "$REPO"
FAST=0
[ "${1:-}" = "--fast" ] && FAST=1

failed=0
step() { echo; echo "==> $*"; }

step "sozdizimi (bash -n)"
# -co: henuz commit edilmemis yeni dosyalar da taransin
mapfile -t files < <(git ls-files -co --exclude-standard -- '*.sh' bash/.bashrc)
for f in "${files[@]}"; do
    if bash -n "$f"; then echo "ok   $f"; else echo "HATA $f"; failed=$((failed + 1)); fi
done

step "shellcheck"
SC="${SHELLCHECK:-$(command -v shellcheck || true)}"
if [ -n "$SC" ]; then
    # .bashrc dosyasi Ubuntu iskeletinden geliyor: yalniz bizim eklediklerimizi degil tumunu tarar
    for f in "${files[@]}"; do
        if "$SC" -x -s bash -S warning "$f"; then echo "ok   $f"; else failed=$((failed + 1)); fi
    done
else
    echo "UYARI: shellcheck kurulu degil (sudo apt install shellcheck); bu adim atlandi."
fi

step "kabuk testleri"
bash tests/shell_test.sh || failed=$((failed + 1))

if [ "$FAST" -eq 0 ]; then
    step "tmux eklenti testi"
    bash tests/tmux_plugins_test.sh || failed=$((failed + 1))
    step "nvim testleri"
    bash nvim/tests/run.sh || failed=$((failed + 1))
else
    echo; echo "(--fast: nvim testi atlandi)"
fi

echo
if [ "$failed" -eq 0 ]; then echo "TUM KONTROLLER GECTI"; else echo "$failed ADIM BASARISIZ"; exit 1; fi

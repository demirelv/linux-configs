#!/usr/bin/env bash
# Tek komutla tum kontroller: sozdizimi, shellcheck, kabuk/kanca/arac/dokuman, tmux eklenti ve nvim testleri.
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
failed_steps=()
step() { echo; echo "==> $*"; }
fail() { failed=$((failed + 1)); failed_steps+=("$1"); }

step "sozdizimi (bash -n)"
# -co: henuz commit edilmemis yeni dosyalar da taransin
mapfile -t files < <(git ls-files -co --exclude-standard -- '*.sh' bash/.bashrc .githooks/pre-commit bin/lc-help)
for f in "${files[@]}"; do
    if bash -n "$f"; then echo "ok   $f"; else echo "HATA $f"; fail "bash -n $f"; fi
done

step "shellcheck"
SC="${SHELLCHECK:-$(command -v shellcheck || true)}"
if [ -n "$SC" ]; then
    # .bashrc dosyasi Ubuntu iskeletinden geliyor: yalniz bizim eklediklerimizi degil tumunu tarar
    for f in "${files[@]}"; do
        if "$SC" -x -s bash -S warning "$f"; then echo "ok   $f"; else fail "shellcheck $f"; fi
    done
else
    echo "UYARI: shellcheck kurulu degil (sudo apt install shellcheck); bu adim atlandi."
fi

step "kabuk testleri"
bash tests/shell_test.sh || fail "kabuk testleri"
bash tests/hook_test.sh || fail "pre-commit kanca testi"
bash tests/tools_test.sh || fail "arac kurulum testi"
bash tests/docs_test.sh || fail "dokuman testi"
bash tests/lc_help_test.sh || fail "lc-help testi"

if [ "$FAST" -eq 0 ]; then
    step "tmux eklenti testi"
    bash tests/tmux_plugins_test.sh || fail "tmux eklenti testi"
    step "nvim testleri"
    bash nvim/tests/run.sh || fail "nvim testleri"
else
    echo; echo "(--fast: nvim testi atlandi)"
fi

echo
if [ "$failed" -eq 0 ]; then echo "TUM KONTROLLER GECTI"; else echo "$failed ADIM BASARISIZ: ${failed_steps[*]}"; exit 1; fi

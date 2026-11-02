#!/usr/bin/env bash
# tools/install-tools.sh testi: sahte apt-cache/dpkg/apt-get ile (gercek paket kurmaz, sudo gerektirmez).
set -Eeuo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "${tmp:?}" 2>/dev/null || true' EXIT

failed=0
ok() { local msg="$1"; shift; if "$@"; then echo "PASS $msg"; else echo "FAIL $msg"; failed=$((failed + 1)); fi; }
not() { ! "$@"; }
has() { grep -qF -- "$2" <<<"$1"; }

bin="$tmp/bin"; mkdir -p "$bin"
export HOME="$tmp/home"; mkdir -p "$HOME"
export GIT_CONFIG_GLOBAL="$HOME/.gitconfig"; : > "$GIT_CONFIG_GLOBAL"
export TOOLS_SUDO=""            # sudo yok; sahte apt-get dogrudan cagrilir
export STUB_LOG="$tmp/apt.log" STUB_MISSING="$tmp/missing" STUB_INSTALLED="$tmp/installed"
: > "$STUB_MISSING"; : > "$STUB_INSTALLED"

cat > "$bin/apt-cache" <<'EOS'
#!/usr/bin/env bash
# apt-cache policy <paket>
if grep -qxF -- "$2" "$STUB_MISSING"; then echo "  Candidate: (none)"; else echo "  Candidate: 1.0"; fi
EOS
cat > "$bin/dpkg" <<'EOS'
#!/usr/bin/env bash
# dpkg -s <paket>
grep -qxF -- "$2" "$STUB_INSTALLED"
EOS
cat > "$bin/apt-get" <<'EOS'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$STUB_LOG"
EOS
chmod +x "$bin"/*
# Gercek araclar PATH'te kalsin ama sahteler once gelsin; sistemde gercek fd/bat/delta olsa testi bozmasin diye
# onlari gizleyen bos bir dizin yerine PATH'i kontrollu kuruyoruz.
export PATH="$bin:/usr/bin:/bin"
for t in fd fdfind bat batcat delta; do
    if command -v "$t" >/dev/null 2>&1; then echo "SKIP $t sistemde kurulu; sahte-PATH testi guvenilmez olabilir"; fi
done

run() { bash "$REPO/tools/install-tools.sh" "$@" 2>&1; }

out="$(run --dry-run core)"
ok "dry-run: kurulacaklari listeler, bir sey kurmaz" bash -c '[[ "$1" == *"kurulacak    : cppcheck"* ]] && [ ! -s "$2" ]' _ "$out" "$STUB_LOG"
ok "dry-run: varsayilan gruplar core + git" has "$(run --dry-run)" "Gruplar: core git"
ok "bilinmeyen grup hata verir" not bash "$REPO/tools/install-tools.sh" xyz

printf 'eza\n' > "$STUB_MISSING"; printf 'bat\n' > "$STUB_INSTALLED"
out="$(run --dry-run core)"
ok "apt'te olmayan paket atlanir ve belirtilir" has "$out" "apt'te yok   : eza"
ok "zaten kurulu paket tekrar kurulmaz" has "$out" "zaten kurulu : bat"

: > "$STUB_LOG"
run core >/dev/null
log="$(cat "$STUB_LOG")"
ok "apt-get install -y cagrilir" has "$log" "install -y"
ok "kurulacak paketler komutta" has "$log" "cppcheck"
ok "eksik paket (eza) komutta yok" not has "$log" "eza"
ok "kurulu paket (bat) komutta yok" not has "$log" " bat "

# fdfind -> fd, batcat -> bat baglari; ikinci calistirma yedek uretmez
printf '#!/bin/sh\n' > "$bin/fdfind"; printf '#!/bin/sh\n' > "$bin/batcat"; chmod +x "$bin/fdfind" "$bin/batcat"
run core >/dev/null; run core >/dev/null
ok "fdfind ~/.local/bin/fd olarak baglandi" test "$(readlink "$HOME/.local/bin/fd")" = "$bin/fdfind"
ok "batcat ~/.local/bin/bat olarak baglandi" test "$(readlink "$HOME/.local/bin/bat")" = "$bin/batcat"
ok "tekrar calistirma yedek dosya uretmez" not bash -c 'ls "$1"/.local/bin/*.bak.* >/dev/null 2>&1' _ "$HOME"

# delta yokken git'e dokunulmaz
ok "delta yokken ~/.gitconfig.delta olusmaz" test ! -e "$HOME/.gitconfig.delta"
ok "delta yokken core.pager ayarsiz" test -z "$(git config --global --includes core.pager || true)"

# delta varken: dosya kopyalanir, include bir kez eklenir, pager devreye girer
printf '#!/bin/sh\n' > "$bin/delta"; chmod +x "$bin/delta"
run core >/dev/null; run core >/dev/null
ok "delta varken ~/.gitconfig.delta kopyalandi" cmp -s "$REPO/git/delta.gitconfig" "$HOME/.gitconfig.delta"
# shellcheck disable=SC2088  # ~ bilerek literal: git'in yazdigi deger bu
ok "include.path tam bir kez" test "$(git config --global --get-all include.path | grep -cxF '~/.gitconfig.delta')" -eq 1
ok "core.pager = delta (include ile)" test "$(git config --global --includes core.pager)" = "delta"

echo
if [ "$failed" -eq 0 ]; then echo "TUMU GECTI"; else echo "$failed KONTROL BASARISIZ"; exit 1; fi

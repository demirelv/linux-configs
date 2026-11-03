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
# PATH kontrollu: sistemin /usr/bin'i, ama fd/fdfind/bat/batcat/delta gorunmeden (kurulu olsalar testi bozar).
sysbin="$tmp/sysbin"; mkdir -p "$sysbin"
for f in /usr/bin/* /bin/*; do
    n="${f##*/}"
    case "$n" in fd|fdfind|bat|batcat|delta|snap|glow) continue ;; esac
    [ -e "$sysbin/$n" ] || ln -s "$f" "$sysbin/$n" 2>/dev/null || true
done
export PATH="$bin:$sysbin"

run() { bash "$REPO/tools/install-tools.sh" "$@" 2>&1; }

out="$(run --dry-run core)"
ok "dry-run: kurulacaklari listeler, bir sey kurmaz" bash -c '[[ "$1" == *"kurulacak    : cppcheck"* ]] && [ ! -s "$2" ]' _ "$out" "$STUB_LOG"
ok "dry-run: varsayilan gruplar core + git" has "$(run --dry-run)" "Gruplar: core git"
ok "bilinmeyen grup hata verir" not bash "$REPO/tools/install-tools.sh" xyz
ok "dev grubu ripgrep git-absorb gping kurar" has "$(run --dry-run dev)" "kurulacak    : ripgrep git-absorb gping"
cdbg="$(run --dry-run c-debug)"
ok "c-debug: strace gdb bpftrace kurulur" has "$cdbg" "strace gdb bpftrace"
ok "c-debug: perf calisan kernel'in paketiyle (linux-tools-\$(uname -r))" has "$cdbg" "linux-tools-$(uname -r)"
ok "net grubu socat kurar" has "$(run --dry-run net)" "socat"
ok "misc grubu pv ve visidata kurar" has "$(run --dry-run misc)" "pv visidata"

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

# extra grubu: cargo/pipx ile kurar; kurulu olani atlar; birinin hatasi digerlerini durdurmaz
cat > "$bin/cargo" <<'EOS'
#!/usr/bin/env bash
printf 'cargo %s\n' "$*" >> "$STUB_LOG"
case "$*" in *tokei*) exit 1 ;; esac
EOS
cat > "$bin/pipx" <<'EOS'
#!/usr/bin/env bash
printf 'pipx %s\n' "$*" >> "$STUB_LOG"
EOS
cat > "$bin/snap" <<'EOS'
#!/usr/bin/env bash
printf 'snap %s\n' "$*" >> "$STUB_LOG"
case "$*" in *failsnap*) exit 1 ;; esac
EOS
chmod +x "$bin/cargo" "$bin/pipx" "$bin/snap"

# vtop kaynaktan kurulur (git clone + make install): ag yok, sahte yerel git deposu ve sabit commit
vsrc="$tmp/vtop-src"; mkdir -p "$vsrc"
printf '#!/bin/sh\necho vtop-fixture\n' > "$vsrc/vtop.sh"
printf 'PREFIX ?= /usr/local\nall: ;\ninstall:\n\tinstall -D -m 755 vtop.sh $(DESTDIR)$(PREFIX)/bin/vtop\n' > "$vsrc/Makefile"
git -C "$vsrc" init -q -b main
git -C "$vsrc" add -A
git -C "$vsrc" -c user.name=t -c user.email=t@t commit -q -m fixture
vref="$(git -C "$vsrc" rev-parse HEAD)"
export TOOLS_VTOP_URL="$vsrc" TOOLS_VTOP_REF="$vref"
printf '#!/bin/sh\n' > "$bin/starship"; chmod +x "$bin/starship"   # zaten kurulu sayilir
: > "$STUB_LOG"
out="$(run extra || true)"
log="$(cat "$STUB_LOG")"
ok "extra: surum sabitli --locked cargo install" has "$log" "cargo install --locked atuin --version 18.8.0"
ok "extra: kurulu starship atlanir" not has "$log" "starship"
ok "extra: uv pipx ile kurulur" has "$log" "pipx install uv"
ok "extra: biri (tokei) basarisiz olsa da digerleri kurulur" has "$log" "cargo install --locked xh --version"
ok "extra: basarisiz arac raporlanir" has "$out" "kurulamayan extra araclar: tokei"
ok "extra: dry-run cargo cagirmaz" test "$(: > "$STUB_LOG"; run --dry-run extra >/dev/null; wc -c < "$STUB_LOG")" -eq 0
ok "all extra'yi de icerir" has "$(run --dry-run all)" "cargo/pipx"
ok "extra yokken varsayilan cargo/pipx satiri yok" not has "$(run --dry-run)" "cargo/pipx"

# vtop: ~/.local/bin altina, sudo'suz; sistemdeki eski /usr/bin/vtop sayilmaz; sabit commit disinda kurulmaz
ok "vtop: onceki extra calismalari ~/.local/bin/vtop kurdu" test -x "$HOME/.local/bin/vtop"
rm -f "$HOME/.local/bin/vtop"
ok "vtop: extra dry-run kaynaktan kurulacagini soyler" has "$(run --dry-run extra)" "kaynaktan    : vtop@"
run extra >/dev/null 2>&1 || true
ok "vtop: extra ~/.local/bin/vtop kurar" test -x "$HOME/.local/bin/vtop"
ok "vtop: kurulan arac calisir" test "$("$HOME/.local/bin/vtop")" = "vtop-fixture"
ok "vtop: kurulu iken tekrar kurulmaz" not has "$(run extra || true)" "==> vtop"
ok "vtop: kurulu iken dry-run kaynaktan satiri bos" has "$(run --dry-run extra)" "kaynaktan    : yok"
rm -f "$HOME/.local/bin/vtop"
out="$(TOOLS_VTOP_REF=0000000000000000000000000000000000000000 run extra || true)"
ok "vtop: yanlis commit kurulmaz ve raporlanir" has "$out" "kurulamayan extra araclar: tokei vtop"
ok "vtop: yanlis commit sonrasi dosya yok" test ! -e "$HOME/.local/bin/vtop"
out="$(TOOLS_VTOP_URL="$tmp/yok" run extra || true)"
ok "vtop: klon basarisizsa digerleri durmaz, vtop raporlanir" has "$out" "kurulamayan extra araclar: tokei vtop"
run extra >/dev/null 2>&1 || true
ok "vtop: sonraki calistirma kurar" test -x "$HOME/.local/bin/vtop"

# glow: apt'te yok, snap ile kurulur (sudo komutu TOOLS_SUDO ile degisir); kurulu ise atlanir
: > "$STUB_LOG"; run extra >/dev/null 2>&1 || true
ok "glow: snap install glow cagrilir" has "$(cat "$STUB_LOG")" "snap install glow"
ok "glow: dry-run snap listesinde" has "$(run --dry-run extra)" "snap         : glow"
printf '#!/bin/sh\n' > "$bin/glow"; chmod +x "$bin/glow"
: > "$STUB_LOG"; run extra >/dev/null 2>&1 || true
ok "glow: kurulu iken tekrar kurulmaz" not has "$(cat "$STUB_LOG")" "snap install"
rm -f "$bin/glow"
mv "$bin/snap" "$bin/snap.off"
out="$(run extra || true)"
ok "glow: snap yoksa raporlanir, digerleri durmaz" has "$out" "kurulamayan extra araclar: tokei glow"
mv "$bin/snap.off" "$bin/snap"

# atuin ilk kurulum: bash gecmisi bir kez iceri alinir, yukari ok tum gecmisi arar (idempotent)
printf '#!/bin/sh\nprintf "atuin %%s\\n" "$*" >> "$STUB_LOG"\n' > "$bin/atuin"; chmod +x "$bin/atuin"
atuin_cfg="$HOME/.config/atuin/config.toml"; atuin_mark="$HOME/.local/share/atuin/.linux-configs-imported"
: > "$STUB_LOG"; run extra >/dev/null 2>&1 || true
ok "atuin: bash gecmisi iceri alinir" has "$(cat "$STUB_LOG")" "atuin import auto"
ok "atuin: yukari ok ayari yazilir" grep -qx 'filter_mode_shell_up_key_binding = "global"' "$atuin_cfg"
ok "atuin: import isareti konur" test -f "$atuin_mark"
: > "$STUB_LOG"; run extra >/dev/null 2>&1 || true
ok "atuin: ikinci calistirmada tekrar import yok" not has "$(cat "$STUB_LOG")" "atuin import"
ok "atuin: ayar tekrar eklenmez" test "$(grep -c filter_mode_shell_up_key_binding "$atuin_cfg")" -eq 1
rm -f "$atuin_mark"; printf 'filter_mode_shell_up_key_binding = "session"\n[sync]\n' > "$atuin_cfg"
run extra >/dev/null 2>&1 || true
ok "atuin: kullanicinin kendi ayari ezilmez" grep -qx 'filter_mode_shell_up_key_binding = "session"' "$atuin_cfg"
ok "atuin: ayar [tablo]'dan once (ust duzey) yazilir" test "$(head -n1 "$(dirname "$atuin_cfg")/config.toml")" != "[sync]"
rm -f "$bin/atuin"

echo
if [ "$failed" -eq 0 ]; then echo "TUMU GECTI"; else echo "$failed KONTROL BASARISIZ"; exit 1; fi

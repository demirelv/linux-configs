#!/usr/bin/env bash
# git/hooks/commit-msg ve bin/lc-issue-hook testi: gecici git depolarinda gercek `git commit` ile.
set -Eeuo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "${tmp:?}" 2>/dev/null || true' EXIT

failed=0
ok() { local msg="$1"; shift; if "$@"; then echo "PASS $msg"; else echo "FAIL $msg"; failed=$((failed + 1)); fi; }
not() { ! "$@"; }
has() { grep -qF -- "$2" <<<"$1"; }

H="$REPO/git/hooks/commit-msg"
msg() { printf '%b' "$1" > "$tmp/m"; "$H" "$tmp/m" 2>"$tmp/err"; }

ok "Issue satiri varsa gecer" msg "Fix thing\n\nbody\n\nIssue: PROJ-1234\n"
ok "Issue satirinda sonda bosluk olabilir" msg "Fix thing\n\nIssue: AB_C-7  \n"
ok "Issue satiri yoksa reddedilir" not msg "Fix thing\n\nbody only\n"
ok "ret mesaji Issue anahtarini ister" has "$(cat "$tmp/err")" "Issue: <KEY>"
ok "kucuk harfli anahtar reddedilir" not msg "Fix\n\nIssue: proj-12\n"
ok "numarasiz anahtar reddedilir" not msg "Fix\n\nIssue: PROJ\n"
ok "yorum satirindaki Issue sayilmaz" not msg "Fix\n\n# Issue: PROJ-1\n"
ok "Merge mesaji atlanir" msg "Merge branch 'x'\n"
ok "fixup! mesaji atlanir" msg "fixup! Fix thing\n"
ok "squash! mesaji atlanir" msg "squash! Fix thing\n"

# gercek git commit + lc-issue-hook
work="$tmp/r"; git init -q "$work"
git -C "$work" config user.name t; git -C "$work" config user.email t@t
I="$REPO/bin/lc-issue-hook"
ok "status: kurulu degil" has "$("$I" status "$work")" "not installed"
ok "install: kurar" has "$("$I" install "$work")" "installed:"
ok "status: kurulu" has "$("$I" status "$work")" "installed:"
ok "install ikinci kez sorunsuz" has "$("$I" install "$work")" "already installed"
echo a > "$work/f"; git -C "$work" add f
ok "git commit Issue'suz reddedilir" not git -C "$work" commit -q -m "no issue"
ok "git commit Issue ile gecer" git -C "$work" commit -q -m "with issue" -m "Issue: PROJ-1"
echo b > "$work/f"; git -C "$work" add f
ok "--no-verify ile atlanir" git -C "$work" commit -q --no-verify -m "skip"
ok "uninstall: kaldirir" has "$("$I" uninstall "$work")" "removed:"
ok "uninstall sonrasi status kurulu degil" has "$("$I" status "$work")" "not installed"

# bizim olmayan hook'a dokunmaz
printf '#!/bin/sh\nexit 0\n' > "$work/.git/hooks/commit-msg"; chmod +x "$work/.git/hooks/commit-msg"
ok "baska bir commit-msg varsa install reddeder" not "$I" install "$work"
ok "baska hook'a dokunulmadi" grep -q "exit 0" "$work/.git/hooks/commit-msg"
ok "uninstall bizim olmayan hook'u silmez" test -f "$work/.git/hooks/commit-msg" -a "$("$I" uninstall "$work" >/dev/null; echo $?)" = 0

ok "linux-configs deposunun kendisine dokunmaz" not "$I" install "$REPO"
ok "git deposu degilse hata" not "$I" install "$tmp"

echo
if [ "$failed" -eq 0 ]; then echo "TUMU GECTI"; else echo "$failed KONTROL BASARISIZ"; exit 1; fi

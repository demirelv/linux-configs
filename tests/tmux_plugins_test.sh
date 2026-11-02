#!/usr/bin/env bash
# tmux.conf + resurrect/continuum testi. Gecici HOME ve gecici tmux soketi; ag gerekir (GitHub klonu).
set -Eeuo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
# Gecici dizini silmek, kapanmakta olan tmux/nvim sureclerinin son yazmalariyla yarisabilir;
# temizlik hatasi testin sonucunu bozmasin (set -e altinda trap icindeki hata cikis kodunu degistirir).
cleanup() {
    TMUX_TMPDIR="$tmp/sock" tmux kill-server 2>/dev/null || true
    sleep 1
    rm -rf -- "${tmp:?}" 2>/dev/null || rm -rf -- "${tmp:?}" 2>/dev/null || true
}
trap cleanup EXIT

failed=0
# ok <mesaj> <komut...>: komut basariliysa PASS (stdin komuta gecer)
ok() { local msg="$1"; shift; if "$@"; then echo "PASS $msg"; else echo "FAIL $msg"; failed=$((failed + 1)); fi; }
both_set() { [ -n "$1" ] && [ -n "$2" ]; }
quiet() { ! grep -qiE 'no such file|returned|error' <<<"$1"; }
not() { ! "$@"; }
saved_has() { [ -n "$1" ] && grep -q "$2" "$1"; }

# install.sh'deki sabit commit'ler tek kaynaktan okunur (kopyalanip eskimesin)
pin() { grep -A1 "tmux-plugins/$1" "$REPO/install.sh" | grep -oE '[0-9a-f]{40}' | head -n1; }
SHA_R="$(pin tmux-resurrect)"; SHA_C="$(pin tmux-continuum)"
ok "install.sh'de iki eklenti commit'i sabitli" both_set "$SHA_R" "$SHA_C"

# HOME degisince git, gercek ~/.gitconfig'teki ag ayarlarini (proxy, CA) kaybeder; ayni dosyayi okumaya devam etsin.
[ -f "$HOME/.gitconfig" ] && export GIT_CONFIG_GLOBAL="$HOME/.gitconfig"
export HOME="$tmp/home" TMUX_TMPDIR="$tmp/sock"; mkdir -p "$HOME" "$TMUX_TMPDIR"; unset TMUX
conf="$REPO/tmux/.tmux.conf"

# 1) Eklenti kurulu DEGILKEN conf hatasiz yuklenmeli (if-shell korumasi)
out="$(tmux -f "$conf" start-server \; show -g @continuum-restore 2>&1 || true)"
ok "eklenti yokken tmux.conf hatasiz" quiet "$out"
tmux kill-server 2>/dev/null || true

# 2) Eklentileri sabit commit'e kur, conf'u yukle
# shellcheck source=../lib/link.sh
source "$REPO/lib/link.sh"
clone_pinned https://github.com/tmux-plugins/tmux-resurrect "$HOME/.tmux/plugins/tmux-resurrect" "$SHA_R" >/dev/null
clone_pinned https://github.com/tmux-plugins/tmux-continuum "$HOME/.tmux/plugins/tmux-continuum" "$SHA_C" >/dev/null
ok "tmux-resurrect sabit commit'te" test "$(git -C "$HOME/.tmux/plugins/tmux-resurrect" rev-parse HEAD)" = "$SHA_R"
ok "tmux-continuum sabit commit'te" test "$(git -C "$HOME/.tmux/plugins/tmux-continuum" rev-parse HEAD)" = "$SHA_C"

tmux -f "$conf" new-session -d -s t1
sleep 1
keys="$(tmux list-keys 2>&1)"
ok "resurrect: Prefix + Ctrl-s kaydet kisayolu bagli" grep -q 'resurrect.*save.sh' <<<"$keys"
ok "resurrect: Prefix + Ctrl-r geri yukle kisayolu bagli" grep -q 'resurrect.*restore.sh' <<<"$keys"
ok "continuum-restore on" test "$(tmux show -gv @continuum-restore)" = "on"
# NOT: continuum otomatik kaydi (status-right kancasi) yalniz makinede baska tmux sureci yokken baslatir ve
# "baska surec"i komut satirinda "tmux" gecen her seyle sayar (bu test betigi dahil). Bu yuzden kanca burada
# guvenilir olculemez; kaydetme yolu asagida resurrect ile dogrudan test edilir.
ok "prefix hala C-a" test "$(tmux show -gv prefix)" = "C-a"
ok "escape-time 10 ms (nvim'de Esc gecikmesi yok)" test "$(tmux show -sv escape-time)" = "10"

# nvim <-> tmux gezintisi: baglar ve gercek tespit (sol pane bash, sag pane nvim)
root_keys="$(tmux list-keys -T root)"
for k in C-h C-j C-k C-l; do
    ok "gezinti: root $k if-shell ile bagli" grep -qE "bind-key +-T root $k +if-shell" <<<"$root_keys"
    ok "gezinti: copy-mode-vi $k bagli" grep -qE "bind-key +-T copy-mode-vi $k +select-pane" <<<"$(tmux list-keys -T copy-mode-vi)"
    ok "gezinti: Prefix + $k tusu uygulamaya yollar" grep -qE "bind-key +-T prefix $k +send-keys $k" <<<"$(tmux list-keys -T prefix)"
done

left="$(tmux display-message -p -t t1 '#{pane_id}')"
right="$(tmux split-window -h -t t1 -P -F '#{pane_id}')"
tmux send-keys -t "$right" "nvim -u NONE" Enter
sleep 2
cond="$(tmux show-environment -g is_vim | sed 's/^is_vim=//')"
is_vim_pane() { # is_vim_pane <pane-id>: conf'taki ayni kosulu o pane'in tty'sine uygular
    local tty; tty="$(tmux display-message -p -t "$1" '#{pane_tty}')"
    sh -c "${cond//\#\{pane_tty\}/$tty}"
}
ok "gezinti: nvim calisan pane vim sayilir (tus nvim'e gider)" is_vim_pane "$right"
ok "gezinti: bash calisan pane vim sayilmaz (tmux pane degistirir)" not is_vim_pane "$left"
tmux send-keys -t "$right" ":qa!" Enter

# 3) Kaydet -> kaydi oku: gercek bir kayit dosyasi olusmali
tmux new-window -d -t t1: -n ikinci
tmux run-shell "$HOME/.tmux/plugins/tmux-resurrect/scripts/save.sh" >/dev/null 2>&1 || true
saved="$(ls "$HOME"/.local/share/tmux/resurrect/*.txt "$HOME"/.tmux/resurrect/*.txt 2>/dev/null | head -n1 || true)"
ok "resurrect: oturum kaydedilir (pencere adi kayitta)" saved_has "$saved" ikinci

echo
if [ "$failed" -eq 0 ]; then echo "TUMU GECTI"; else echo "$failed KONTROL BASARISIZ"; exit 1; fi

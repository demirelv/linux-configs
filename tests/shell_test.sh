#!/usr/bin/env bash
# Kabuk tarafi testleri: lib/link.sh, .bashrc.local yukleme, tm/tmw/tmj tamamlamasi.
# Gecici HOME ve gecici tmux soketi kullanir; gercek HOME'a ve acik tmux oturumlarina dokunmaz.
set -Eeuo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
cleanup() {
    TMUX_TMPDIR="$tmp/tmux" tmux kill-server 2>/dev/null || true
    rm -rf -- "${tmp:?}"
}
trap cleanup EXIT

failed=0
check() { # check <kosul-basarili-mi:0/1> <mesaj>
    if [ "$1" -eq 0 ]; then echo "PASS $2"; else echo "FAIL $2"; failed=$((failed + 1)); fi
}
eq() { [ "$1" = "$2" ]; echo $?; } # eq <bulunan> <beklenen> -> 0/1

# shellcheck source=../lib/link.sh
source "$REPO/lib/link.sh"

# ---- link_file ----
mkdir -p "$tmp/src" "$tmp/home"
echo "kaynak" > "$tmp/src/a"
link_file "$tmp/src/a" "$tmp/home/.a" >/dev/null
if [ -L "$tmp/home/.a" ] && [ "$(readlink "$tmp/home/.a")" = "$tmp/src/a" ]; then r=0; else r=1; fi
check "$r" "link_file: temiz hedefe sembolik bag kurar"

out="$(link_file "$tmp/src/a" "$tmp/home/.a")"
check "$([[ "$out" == *"bagli:"* ]] && ! ls "$tmp"/home/.a.bak.* >/dev/null 2>&1; echo $?)" "link_file: ikinci calistirma yedek olusturmaz (idempotent)"

echo "eski icerik" > "$tmp/home/.b"
link_file "$tmp/src/a" "$tmp/home/.b" >/dev/null
bak="$(ls "$tmp"/home/.b.bak.* 2>/dev/null | head -n1 || true)"
if [ -L "$tmp/home/.b" ] && [ -n "$bak" ] && [ "$(cat "$bak")" = "eski icerik" ]; then r=0; else r=1; fi
check "$r" "link_file: var olan dosyayi silmez, .bak olarak yana tasir"

ln -s "$tmp/src/baska" "$tmp/home/.c"
link_file "$tmp/src/a" "$tmp/home/.c" >/dev/null
check "$([ "$(readlink "$tmp/home/.c")" = "$tmp/src/a" ] && ls "$tmp"/home/.c.bak.* >/dev/null 2>&1; echo $?)" "link_file: yanlis bagi duzeltir ve eskisini yedekler"

# ---- clone_pinned (yerel depo, ag gerekmez) ----
git init -q "$tmp/up"
git -C "$tmp/up" -c user.name=t -c user.email=t@t commit -q --allow-empty -m bir
sha1="$(git -C "$tmp/up" rev-parse HEAD)"
git -C "$tmp/up" -c user.name=t -c user.email=t@t commit -q --allow-empty -m iki
sha2="$(git -C "$tmp/up" rev-parse HEAD)"
clone_pinned "$tmp/up" "$tmp/plug" "$sha1" >/dev/null
check "$(eq "$(git -C "$tmp/plug" rev-parse HEAD)" "$sha1")" "clone_pinned: istenen commit'e sabitler"
out="$(clone_pinned "$tmp/up" "$tmp/plug" "$sha1")"
if [[ "$out" == *"mevcut:"* ]]; then r=0; else r=1; fi
check "$r" "clone_pinned: ayni commit ise dokunmaz"
clone_pinned "$tmp/up" "$tmp/plug" "$sha2" >/dev/null
check "$(eq "$(git -C "$tmp/plug" rev-parse HEAD)" "$sha2")" "clone_pinned: commit degisince gunceller"

# ---- .bashrc: ~/.bashrc.local yukleme (repo .bashrc'si sembolik bagla, gercek bash -i ile) ----
fakehome="$tmp/fh"; mkdir -p "$fakehome"
ln -s "$REPO/bash/.bashrc" "$fakehome/.bashrc"
got="$(HOME="$fakehome" bash -ic 'echo "LOCAL=${LOCAL_TEST:-yok}"' 2>/dev/null | grep -o 'LOCAL=.*' || true)"
check "$(eq "$got" "LOCAL=yok")" ".bashrc: .bashrc.local yokken hatasiz acilir"
echo 'export LOCAL_TEST=var' > "$fakehome/.bashrc.local"
got="$(HOME="$fakehome" bash -ic 'echo "LOCAL=${LOCAL_TEST:-yok}"' 2>/dev/null | grep -o 'LOCAL=.*' || true)"
check "$(eq "$got" "LOCAL=var")" ".bashrc: ~/.bashrc.local okunuyor"
got="$(HOME="$fakehome" bash -ic 'type -t tm tmw tmj | tr "\n" " "' 2>/dev/null | tail -n1)"
check "$(eq "$got" "function function function ")" ".bashrc: tm/tmw/tmj fonksiyonlari yuklu"

# ---- tamamlama: izole tmux sunucusu ----
export TMUX_TMPDIR="$tmp/tmux"; mkdir -p "$TMUX_TMPDIR"
unset TMUX
tmux new-session -d -s alpha
tmux new-window -d -t alpha:
tmux new-session -d -s beta

# .bashrc'deki tamamlama blogunu ayiklayip yukle (tum .bashrc interaktif korumali)
comp_src="$tmp/comp.bash"
sed -n '/^_tm_words() {/,/^complete -F _tmj_complete tmj/p' "$REPO/bash/.bashrc" > "$comp_src"
run_comp() { # run_comp <fonksiyon> <cword> <kelimeler...> -> COMPREPLY (bosluklu)
    local fn="$1" cword="$2"; shift 2
    # shellcheck disable=SC2016
    bash -c 'source "$1"; fn="$2"; COMP_CWORD="$3"; shift 3; COMP_WORDS=("$@"); COMPREPLY=(); "$fn"; echo "${COMPREPLY[*]}"' _ "$comp_src" "$fn" "$cword" "$@"
}
check "$(eq "$(run_comp _tm_complete 1 tm al)" "alpha")" "tamamlama: tm al -> alpha"
check "$(eq "$(run_comp _tm_complete 1 tm '')" "alpha beta")" "tamamlama: tm <Tab> tum session'lari verir"
check "$(eq "$(run_comp _tmw_complete 1 tmw alpha:)" "alpha:1 alpha:2")" "tamamlama: tmw alpha: -> alpha:1 alpha:2"
check "$(eq "$(run_comp _tmw_complete 2 tmw alpha:1 be)" "beta")" "tamamlama: tmw ikinci arguman session adi"
check "$(eq "$(run_comp _tmj_complete 2 tmj alpha:1 b)" "beta:1")" "tamamlama: tmj ikinci arguman pencere"
check "$(eq "$(run_comp _tmw_complete 3 tmw alpha:1 beta x)" "")" "tamamlama: fazla arguman icin oneri yok"

# bash-completion yuklu ve ":" ayri kelime sayiliyorsa (gercek terminal davranisi)
if [ -f /usr/share/bash-completion/bash_completion ]; then
    got="$(bash -c '
        source /usr/share/bash-completion/bash_completion
        source "$1"
        COMP_LINE="tmw alpha:"; COMP_POINT=${#COMP_LINE}
        COMP_WORDS=(tmw alpha :); COMP_CWORD=2; COMPREPLY=()
        _tmw_complete; echo "${COMPREPLY[*]}"' _ "$comp_src" 2>/dev/null)"
    check "$(eq "$got" "1 2")" "tamamlama: bash-completion ile 'alpha:' sonrasi 1 2 (onek kirpilir)"
else
    echo "SKIP bash-completion yuklu degil"
fi

echo
if [ "$failed" -eq 0 ]; then echo "TUMU GECTI"; else echo "$failed KONTROL BASARISIZ"; exit 1; fi

#!/usr/bin/env bash
# Kabuk tarafi testleri: lib/link.sh, .bashrc.local yukleme, tm/tmw/tmj tamamlamasi.
# Gecici HOME ve gecici tmux soketi kullanir; gercek HOME'a ve acik tmux oturumlarina dokunmaz.
set -Eeuo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
cleanup() {
    TMUX_TMPDIR="$tmp/tmux" tmux kill-server 2>/dev/null || true
    rm -rf -- "${tmp:?}" 2>/dev/null || true
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

# ---- gunluk kullanim yardimcilari: EDITOR, gecmis, bilet tamamlamasi, tp, tmuxt ----
okc() { local msg="$1"; shift; if "$@"; then echo "PASS $msg"; else echo "FAIL $msg"; failed=$((failed + 1)); fi; }
has() { grep -qF -- "$2" <<<"$1"; }
unset TMUX
fh2="$tmp/fh2"; mkdir -p "$fh2" "$tmp/bin" "$tmp/proj/alpha.proj" "$tmp/proj/beta"
ln -s "$REPO/bash/.bashrc" "$fh2/.bashrc"
rcrun() { HOME="$fh2" PATH="$tmp/bin:$PATH" bash -ic "$1" 2>/dev/null; } # gercek interaktif .bashrc ile

# git editoru
okc "git: core.editor nvim" test "$(git config --file "$REPO/git/.gitconfig" core.editor)" = "nvim"

# EDITOR: nvim varsa nvim olur; bilerek ayarlanmis baska editor ezilmez
if command -v nvim >/dev/null 2>&1; then
    okc "EDITOR bossa nvim olur" test "$(env -u EDITOR -u VISUAL HOME="$fh2" bash -ic 'echo "E=$EDITOR V=$VISUAL"' 2>/dev/null | grep -o 'E=.*')" = "E=nvim V=nvim"
    okc "EDITOR=vim ise nvim olur" test "$(EDITOR=vim VISUAL=vi HOME="$fh2" bash -ic 'echo "E=$EDITOR V=$VISUAL"' 2>/dev/null | grep -o 'E=.*')" = "E=nvim V=nvim"
    okc "bilerek ayarlanmis editor ezilmez" test "$(EDITOR=emacs VISUAL=emacs HOME="$fh2" bash -ic 'echo "E=$EDITOR"' 2>/dev/null | grep -o 'E=.*')" = "E=emacs"
else
    echo "SKIP EDITOR testleri (nvim kurulu degil)"
fi

# gecmis: PROMPT_COMMAND'da tek kez, .bashrc iki kez okunsa da
pc="$(rcrun 'source ~/.bashrc; source ~/.bashrc; echo "PC=$PROMPT_COMMAND"' | grep -o 'PC=.*')"
okc "gecmis: 'history -a' PROMPT_COMMAND'da tam bir kez" test "$(grep -o 'history -a' <<<"$pc" | wc -l)" -eq 1

# vimt / vimj $EDITOR kullanir
cat > "$tmp/bin/fakeeditor" <<EOS
#!/usr/bin/env bash
printf '%s\n' "\$*" > "$tmp/editor.args"
EOS
chmod +x "$tmp/bin/fakeeditor"
EDITOR="$tmp/bin/fakeeditor" HOME="$fh2" bash -ic 'vimt RTS-9; vimj RTS-9' >/dev/null 2>&1 || true
okc "vimj de \$EDITOR ile acar (notes.jira)" grep -q 'FixedIssues/RTS-9/notes.jira' "$tmp/editor.args"
okc "vimt klasoru olusturur" test -d "$fh2/Documents/FixedIssues/RTS-9"

# bilet klasoru tamamlamasi
mkdir -p "$fh2/Documents/FixedIssues/RTS-1" "$fh2/Documents/FixedIssues/RTS-22" "$fh2/Documents/FixedIssues/ABC-3"
sed -n '/^_ticket_complete() {/,/^}/p' "$REPO/bash/.bashrc" > "$tmp/tc.bash"
tcomp() { HOME="$fh2" bash -c 'source "$1"; COMP_CWORD="$2"; shift 2; COMP_WORDS=("$@"); COMPREPLY=(); _ticket_complete; echo "${COMPREPLY[*]}"' _ "$tmp/tc.bash" "$@"; }
okc "bilet tamamlama: cdt RTS<Tab> -> RTS-1 RTS-22 (sirali)" test "$(tcomp 1 cdt RTS | tr ' ' '\n' | sort | tr '\n' ' ')" = "RTS-1 RTS-22 RTS-9 "
okc "bilet tamamlama: ikinci arguman icin oneri yok" test -z "$(tcomp 2 cdt RTS-1 x)"

# tp ve tm: tmux'u kayit eden bir taklitle (gercek oturum acmadan) dogru komutlari uretiyor mu
printf '#!/usr/bin/env bash\nprintf "%%s\\n" "${FZF_PICK:-}"\n[ -n "${FZF_PICK:-}" ]\n' > "$tmp/bin/fzf"; chmod +x "$tmp/bin/fzf"
stub='tmux() { printf "%s\n" "$*" >> "$LOG"; return 1; }'
LOG="$tmp/tp.log"; export LOG
: > "$LOG"; FZF_PICK=beta TP_ROOT="$tmp/proj" rcrun "$stub; tp" >/dev/null || true
okc "tp (tmux disinda): klasorde yeni session baslatir" grep -qxF "new -A -s beta -c $tmp/proj/beta" "$LOG"
: > "$LOG"; TMUX=x FZF_PICK=beta TP_ROOT="$tmp/proj" rcrun "$stub; tp" >/dev/null || true
okc "tp (tmux icinde): olusturur ve gecer" bash -c 'grep -qxF "new -d -s beta -c '"$tmp"'/proj/beta" "$1" && grep -qxF "switch-client -t =beta" "$1"' _ "$LOG"
: > "$LOG"; FZF_PICK=alpha.proj TP_ROOT="$tmp/proj" rcrun "$stub; tp" >/dev/null || true
okc "tp: '.' iceren klasor adi '_' olur (tmux yasagi)" grep -qxF "new -A -s alpha_proj -c $tmp/proj/alpha.proj" "$LOG"
: > "$LOG"; FZF_PICK="" TP_ROOT="$tmp/proj" rcrun "$stub; tp" >/dev/null || true
okc "tp: secim iptal edilirse tmux'a hic dokunulmaz" test ! -s "$LOG"
okc "tp: olmayan TP_ROOT hata verir" test "$(TP_ROOT="$tmp/yok" rcrun 'tp >/dev/null 2>&1; echo "rc=$?"' | grep -o 'rc=.*')" = "rc=1"
: > "$LOG"; rcrun "$stub; tm foo" >/dev/null || true
okc "tm: tmux disinda new -A ile baglanir" grep -qxF "new -A -s foo" "$LOG"

# tmuxt: seri port otomatik bulunur, arayuz ve IP ayarlanabilir
mkdir -p "$tmp/serial"; : > "$tmp/serial/usb-A"
: > "$LOG"; TMUXT_SERIAL_DIR="$tmp/serial" TMUXT_ETH=eth9 rcrun "$stub; tmuxt RTS-5" >/dev/null || true
tl="$(cat "$LOG")"
okc "tmuxt: seri port by-id dizininden bulunur" has "$tl" "$tmp/serial/usb-A"
okc "tmuxt: RTS biletinde IP 192.168.111.200, arayuz TMUXT_ETH" has "$tl" "ifconfig eth9 192.168.111.200"
okc "tmuxt: bilet notlari vimt ile acilir" has "$tl" "vimt RTS-5"
: > "$LOG"; TMUXT_SERIAL_DIR="$tmp/serial" rcrun "$stub; tmuxt ABC-1" >/dev/null || true
okc "tmuxt: diger biletlerde IP 192.168.2.200, arayuz eth0" has "$(cat "$LOG")" "ifconfig eth0 192.168.2.200"
: > "$LOG"; TMUXT_SERIAL_DIR="$tmp/bos" rcrun "$stub; tmuxt ABC-1" >/dev/null || true
okc "tmuxt: aygit yoksa /dev/ttyUSB0'a duser" has "$(cat "$LOG")" "/dev/ttyUSB0"
: > "$LOG"; TMUXT_SERIAL=/dev/ttyACM7 TMUXT_SERIAL_DIR="$tmp/serial" rcrun "$stub; tmuxt ABC-1" >/dev/null || true
okc "tmuxt: TMUXT_SERIAL otomatik bulmayi gecersiz kilar" has "$(cat "$LOG")" "/dev/ttyACM7"

echo
if [ "$failed" -eq 0 ]; then echo "TUMU GECTI"; else echo "$failed KONTROL BASARISIZ"; exit 1; fi

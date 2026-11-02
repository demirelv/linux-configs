#!/usr/bin/env bash
# Gelistirici araclarini gruplar halinde kurar (apt). Kullanim:
#   tools/install-tools.sh [--dry-run] [grup...]    # varsayilan gruplar: core git
#   tools/install-tools.sh all                      # tum gruplar
# Gruplar: core c-debug net git misc dev extra   (icerikleri ve ne ise yaradiklari: docs/araclar.md)
#
# - `extra` grubu apt'te olmayan araclari cargo ile kurar (surum sabitli, --locked; derleme dakikalar surer) ve
#   uv'yi pipx ile; `all` bunu da icerir. cargo/pipx yoksa onlari apt ile kurar.
# - apt'te olmayan paketi atlar (Ubuntu surumune gore degisir), zaten kurulu olani tekrar kurmaz.
# - Ubuntu'nun fdfind/batcat adlarini ~/.local/bin altinda fd/bat olarak baglar.
# - delta kuruluysa Git'e baglar (~/.gitconfig.delta + include); kurulu degilse git'e dokunmaz.
# - sudo gerekir; TOOLS_SUDO ortam degiskeniyle degistirilir (bos = sudo kullanma; testler icin).
set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/link.sh
source "$REPO_DIR/lib/link.sh"

declare -A TOOL_GROUPS=(
    [core]="cppcheck clang-tidy clang-format bear git-delta fd-find bat eza zoxide direnv shellcheck"
    [c-debug]="ltrace rr lcov doxygen"
    [net]="tshark binwalk qemu-user-static tio lnav moreutils mosh sshfs"
    [git]="tig pre-commit"
    [misc]="entr hyperfine ncdu duf just tmuxp httpie tldr"
    [dev]="ripgrep git-absorb gping"
)
ALL_GROUPS=(core c-debug net git misc dev)

# apt'te olmayan araclar: komut|crate|surum (docs/araclar.md ile ayni; tests/docs_test.sh karsilastirir).
# Surumler rustc 1.88 ile derlenen en yeni surumlerdir (apt'teki Rust); daha yeni surum daha yeni rustc ister.
# mise burada YOK: en eski kurulabilir surumu bile rustc 1.95 ister (docs/araclar.md).
EXTRA_TOOLS=(
    "starship|starship|1.24.1"
    "atuin|atuin|18.8.0"
    "watchexec|watchexec-cli|2.8.0"
    "dust|du-dust|1.2.7"
    "difft|difftastic|0.72.0"
    "ast-grep|ast-grep|0.44.1"
    "procs|procs|0.14.12"
    "tokei|tokei|15.0.0"
    "jless|jless|0.9.0"
    "xh|xh|0.26.3"
)
want_extra=0

dry=0
groups=()
for a in "$@"; do
    case "$a" in
        --dry-run) dry=1 ;;
        -h|--help) sed -n '2,13p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        all) groups=("${ALL_GROUPS[@]}"); want_extra=1 ;;
        extra) want_extra=1 ;;
        *) if [ -n "${TOOL_GROUPS[$a]+x}" ]; then groups+=("$a"); else echo "Bilinmeyen grup: $a (core c-debug net git misc dev extra all)" >&2; exit 1; fi ;;
    esac
done
[ ${#groups[@]} -gt 0 ] || [ "$want_extra" -eq 1 ] || groups=(core git)

candidate() { apt-cache policy "$1" 2>/dev/null | awk '/Candidate:/{print $2}'; }

to_install=(); have=(); missing=()
for g in "${groups[@]}"; do
    for p in ${TOOL_GROUPS[$g]}; do
        if dpkg -s "$p" >/dev/null 2>&1; then have+=("$p")
        else
            c="$(candidate "$p")"
            if [ -z "$c" ] || [ "$c" = "(none)" ]; then missing+=("$p"); else to_install+=("$p"); fi
        fi
    done
done

# extra grubu cargo ve pipx ister: yoksa apt ile kurulur
extra_todo=(); extra_have=()
if [ "$want_extra" -eq 1 ]; then
    for e in "${EXTRA_TOOLS[@]}"; do
        IFS='|' read -r cmd _ _ <<<"$e"
        if command -v "$cmd" >/dev/null 2>&1 || [ -x "$HOME/.cargo/bin/$cmd" ]; then extra_have+=("$cmd"); else extra_todo+=("$e"); fi
    done
    if command -v uv >/dev/null 2>&1 || [ -x "$HOME/.local/bin/uv" ]; then extra_have+=(uv); else extra_todo+=("uv|uv|pipx"); fi
    if [ ${#extra_todo[@]} -gt 0 ]; then
        command -v cargo >/dev/null 2>&1 || dpkg -s cargo >/dev/null 2>&1 || to_install+=(cargo)
        command -v pipx >/dev/null 2>&1 || dpkg -s pipx >/dev/null 2>&1 || to_install+=(pipx)
    fi
fi

extra_label=""; [ "$want_extra" -eq 1 ] && extra_label=" extra"
echo "Gruplar: ${groups[*]:-}$extra_label"
echo "  zaten kurulu : ${have[*]:-yok}"
echo "  kurulacak    : ${to_install[*]:-yok}"
echo "  apt'te yok   : ${missing[*]:-yok}"
if [ "$want_extra" -eq 1 ]; then
    echo "  cargo/pipx   : $(for e in "${extra_todo[@]}"; do IFS='|' read -r _ crate ver <<<"$e"; printf '%s@%s ' "$crate" "$ver"; done)"
    echo "  extra kurulu : ${extra_have[*]:-yok}"
fi

if [ "$dry" -eq 1 ]; then echo "(--dry-run: bir sey kurulmadi)"; exit 0; fi

if [ ${#to_install[@]} -gt 0 ]; then
    sudo_cmd=()
    if [ "$(id -u)" -ne 0 ]; then read -r -a sudo_cmd <<<"${TOOLS_SUDO-sudo}"; fi
    "${sudo_cmd[@]}" apt-get install -y "${to_install[@]}"
fi

# --- extra: cargo (surum sabitli, --locked) ve pipx; biri basarisiz olursa digerleri devam eder ---
extra_failed=()
if [ "$want_extra" -eq 1 ]; then
    for e in "${extra_todo[@]}"; do
        IFS='|' read -r cmd crate ver <<<"$e"
        echo "==> $cmd ($crate $ver)"
        if [ "$ver" = pipx ]; then
            pipx install uv || extra_failed+=("$cmd")
        else
            cargo install --locked "$crate" --version "$ver" || extra_failed+=("$cmd")
        fi
    done
    if [ ${#extra_failed[@]} -gt 0 ]; then echo "UYARI: kurulamayan extra araclar: ${extra_failed[*]}" >&2; fi
fi

# --- kurulum sonrasi: adlar ve Git entegrasyonu (idempotent) ---
mkdir -p "$HOME/.local/bin"
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1 && [ ! -e "$HOME/.local/bin/fd" ]; then
    link_file "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1 && [ ! -e "$HOME/.local/bin/bat" ]; then
    link_file "$(command -v batcat)" "$HOME/.local/bin/bat"
fi
if command -v delta >/dev/null 2>&1; then
    cp "$REPO_DIR/git/delta.gitconfig" "$HOME/.gitconfig.delta"
    # shellcheck disable=SC2088  # ~ bilerek kabukta degil: git include.path degerindeki ~'yi kendisi genisletir
    if ! git config --global --get-all include.path | grep -qxF '~/.gitconfig.delta'; then
        git config --global --add include.path '~/.gitconfig.delta'
        echo "    git: ~/.gitconfig.delta include edildi (delta aktif)"
    fi
fi

echo
echo "Tamam. Yeni bir kabuk ac (zoxide, direnv ve fzf entegrasyonlari .bashrc'de kurulu araclar bulununca etkinlesir)."
echo "cargo ile kurulan araclar ~/.cargo/bin altindadir; yeni kabukta PATH'e girer. Ayrinti: docs/araclar.md"

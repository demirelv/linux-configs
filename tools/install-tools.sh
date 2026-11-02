#!/usr/bin/env bash
# Gelistirici araclarini gruplar halinde kurar (apt). Kullanim:
#   tools/install-tools.sh [--dry-run] [grup...]    # varsayilan gruplar: core git
#   tools/install-tools.sh all                      # tum gruplar
# Gruplar: core c-debug net git misc dev   (icerikleri ve ne ise yaradiklari: docs/araclar.md)
#
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

dry=0
groups=()
for a in "$@"; do
    case "$a" in
        --dry-run) dry=1 ;;
        -h|--help) sed -n '2,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        all) groups=("${ALL_GROUPS[@]}") ;;
        *) if [ -n "${TOOL_GROUPS[$a]+x}" ]; then groups+=("$a"); else echo "Bilinmeyen grup: $a (core c-debug net git misc dev all)" >&2; exit 1; fi ;;
    esac
done
[ ${#groups[@]} -gt 0 ] || groups=(core git)

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

echo "Gruplar: ${groups[*]}"
echo "  zaten kurulu : ${have[*]:-yok}"
echo "  kurulacak    : ${to_install[*]:-yok}"
echo "  apt'te yok   : ${missing[*]:-yok}"

if [ "$dry" -eq 1 ]; then echo "(--dry-run: bir sey kurulmadi)"; exit 0; fi

if [ ${#to_install[@]} -gt 0 ]; then
    sudo_cmd=()
    if [ "$(id -u)" -ne 0 ]; then read -r -a sudo_cmd <<<"${TOOLS_SUDO-sudo}"; fi
    "${sudo_cmd[@]}" apt-get install -y "${to_install[@]}"
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
echo "apt'te olmayan araclar (starship, atuin, mise, uv, watchexec, dust, difftastic, ast-grep ...): docs/araclar.md"

#!/bin/bash
# linux-configs kurulum scripti
# Kullanim:
#   ./install.sh                    # varsayilan kurulum (nvim + araclar + dotfile'lar)
#   ./install.sh --with-wireshark   # wireshark'i da kur
#   ./install.sh --no-dotfiles      # dotfile kopyalamayi atla
#   ./install.sh --no-claude        # Claude Code ayarlarini kurma
#   ./install.sh -h                 # yardim

set -euo pipefail

WITH_WIRESHARK=0
WITH_DOTFILES=1
WITH_CLAUDE=1
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 0
}

while [ $# -gt 0 ]; do
    case "$1" in
        --with-wireshark) WITH_WIRESHARK=1 ;;
        --no-dotfiles)    WITH_DOTFILES=0 ;;
        --no-claude)      WITH_CLAUDE=0 ;;
        -h|--help)        usage ;;
        *) echo "Bilinmeyen parametre: $1 (yardim icin -h)" >&2; exit 1 ;;
    esac
    shift
done

echo "==> apt guncelleniyor"
sudo apt-get update

echo "==> temel araclar kuruluyor"
sudo apt-get install -y \
    git gitk \
    build-essential \
    colordiff \
    meld \
    htop \
    tmux \
    microcom \
    indicator-multiload

# indicator-multiload GNOME'da gorunmesi icin app-indicator eklentisi gerekir.
# Ayarlar:
#   [$(percent(cpu.inuse))][$(size(mem.user))][$(speed(net.down))/$(speed(net.up))]
sudo apt-get install -y gnome-shell-extension-appindicator || true

# unity-tweak-tool: Ubuntu artik GNOME kullaniyor, Unity yok. Kapatildi.
#sudo apt-get install -y unity-tweak-tool

if [ "$WITH_WIRESHARK" -eq 1 ]; then
    echo "==> wireshark kuruluyor"
    # root olmadan paket yakalama sorusunu onceden cevapla (interaktif dialog acilmasin)
    echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y wireshark
    sudo usermod -aG wireshark "$USER"
    echo "    NOT: wireshark grubu icin oturumu kapatip acman gerekiyor."
else
    echo "==> wireshark atlandi (kurmak icin: ./install.sh --with-wireshark)"
fi

# nvim (cscope, ctags, ripgrep, fzf kurulumlarini da icerir)
echo "==> neovim ortami kuruluyor"
( cd "$REPO_DIR/nvim" && bash ./install.sh )

if [ "$WITH_DOTFILES" -eq 1 ]; then
    echo "==> dotfile'lar kopyalaniyor"
    stamp="$(date +%Y%m%d-%H%M%S)"
    for src in "$REPO_DIR/bash/.bashrc" "$REPO_DIR/tmux/.tmux.conf" "$REPO_DIR/git/.gitconfig"; do
        dst="$HOME/$(basename "$src")"
        if [ -e "$dst" ] && ! cmp -s "$src" "$dst"; then
            cp -a "$dst" "$dst.bak.$stamp"
            echo "    yedek: $dst.bak.$stamp"
        fi
        cp "$src" "$dst"
        echo "    kuruldu: $dst"
    done
fi

if [ "$WITH_CLAUDE" -eq 1 ] && [ -x "$REPO_DIR/claude/install.sh" ]; then
    echo "==> Claude Code ayarlari kuruluyor"
    bash "$REPO_DIR/claude/install.sh"
fi

echo
echo "Kurulum tamam. Yeni bir terminal ac (veya: source ~/.bashrc)."

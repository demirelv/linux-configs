#!/bin/bash
# linux-configs kurulum scripti
# Kullanim:
#   ./install.sh                    # varsayilan kurulum (nvim + araclar + dotfile'lar)
#   ./install.sh --with-wireshark   # wireshark'i da kur
#   ./install.sh --no-dotfiles      # dotfile kurulumunu atla
#   ./install.sh --with-tools       # tum gelistirici araclarini kur (varsayilan: core + git gruplari)
#   ./install.sh --no-tools         # gelistirici araclarini kurma
#   ./install.sh -h                 # yardim

set -euo pipefail

WITH_WIRESHARK=0
WITH_DOTFILES=1
TOOLS=default
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/link.sh
source "$REPO_DIR/lib/link.sh"

usage() {
    sed -n '2,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 0
}

while [ $# -gt 0 ]; do
    case "$1" in
        --with-wireshark) WITH_WIRESHARK=1 ;;
        --no-dotfiles)    WITH_DOTFILES=0 ;;
        --with-tools)     TOOLS=all ;;
        --no-tools)       TOOLS=none ;;
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
    shellcheck

# Opsiyonel: yeni Ubuntu surumlerinde paket olmayabilir, kurulum durmasin.
# indicator-multiload GNOME'da gorunmesi icin app-indicator eklentisi gerekir.
# Ayarlar:
#   [$(percent(cpu.inuse))][$(size(mem.user))][$(speed(net.down))/$(speed(net.up))]
sudo apt-get install -y indicator-multiload || echo "    atlandi: indicator-multiload"
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

# Gizli bilgi kancasi (repo public): commit oncesi eklenen satirlari tarar. Makineye ozel desenler
# ~/.config/linux-configs/deny-patterns dosyasina yazilir (repo'ya girmez; ayrintisi .githooks/pre-commit basinda).
if [ -d "$REPO_DIR/.git" ]; then
    git -C "$REPO_DIR" config core.hooksPath .githooks
    echo "==> pre-commit kancasi etkin (core.hooksPath=.githooks)"
fi

if [ "$WITH_DOTFILES" -eq 1 ]; then
    echo "==> dotfile'lar kuruluyor"
    # Sembolik bag: repo'daki dosyayi duzenlemek $HOME'u da gunceller, ayrisma olmaz.
    link_file "$REPO_DIR/bash/.bashrc" "$HOME/.bashrc"
    link_file "$REPO_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    # lc-help: komut/kisayol arama (kabukta Ctrl-x h, tmux Prefix F1). ~/.local/bin PATH'te olmali.
    link_file "$REPO_DIR/bin/lc-help" "$HOME/.local/bin/lc-help"

    # .gitconfig KOPYALANIR (baglanmaz): icindeki kullanici kimligi makineye gore degisebilir.
    stamp="$(date +%Y%m%d-%H%M%S)"
    src="$REPO_DIR/git/.gitconfig"; dst="$HOME/.gitconfig"
    if [ -e "$dst" ] && ! cmp -s "$src" "$dst"; then
        cp -a "$dst" "$dst.bak.$stamp"
        echo "    yedek: $dst.bak.$stamp"
    fi
    cp "$src" "$dst"
    echo "    kuruldu: $dst"

    if [ ! -e "$HOME/.bashrc.local" ]; then
        echo "    NOT: makineye ozel satirlar (PATH, nvm, takma adlar, sirlar) ~/.bashrc.local dosyasina yazilir;"
        echo "         .bashrc onu otomatik okur. Yedeklenen eski .bashrc'den tasiyabilirsin."
    fi

    # tmux oturum kalicligi: resurrect (kaydet/geri yukle) + continuum (otomatik kaydet).
    # tmux-plugins organizasyonu (MIT); kod her tmux acilisinda calisir, bu yuzden commit'e sabit.
    echo "==> tmux eklentileri"
    mkdir -p "$HOME/.tmux/plugins"
    clone_pinned https://github.com/tmux-plugins/tmux-resurrect \
        "$HOME/.tmux/plugins/tmux-resurrect" cff343cf9e81983d3da0c8562b01616f12e8d548
    clone_pinned https://github.com/tmux-plugins/tmux-continuum \
        "$HOME/.tmux/plugins/tmux-continuum" 0698e8f4b17d6454c71bf5212895ec055c578da0
fi

# Gelistirici araclari (delta, fd, bat, zoxide, cppcheck ...): dotfile'lardan SONRA, git include'u ~/.gitconfig'e eklensin diye
case "$TOOLS" in
    default) echo "==> gelistirici araclari (core + git)"; bash "$REPO_DIR/tools/install-tools.sh" ;;
    all)     echo "==> gelistirici araclari (tum gruplar)"; bash "$REPO_DIR/tools/install-tools.sh" all ;;
    none)    echo "==> gelistirici araclari atlandi (sonra: tools/install-tools.sh)" ;;
esac

echo
echo "Kurulum tamam. Yeni bir terminal ac (veya: source ~/.bashrc)."

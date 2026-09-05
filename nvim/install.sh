#!/usr/bin/env bash
# Neovim tabanli C/C++ gelistirme ortami

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing C/C++ dev env with Neovim"

# Ubuntu 24.04+ deposunda neovim yeterince guncel (>=0.11), PPA gerekmiyor.
echo "Installing system packages..."
sudo apt-get update
sudo apt-get install -y \
    neovim \
    clangd \
    build-essential \
    ripgrep \
    fd-find \
    cscope \
    universal-ctags \
    git \
    curl \
    unzip

# Clipboard: X11 icin xclip, Wayland icin wl-clipboard (nvim "+ ve tmux copy-mode kullaniyor)
sudo apt-get install -y xclip wl-clipboard

# Nerd Font (neo-tree / nvim-web-devicons ikonlari icin)
sudo apt-get install -y fonts-jetbrains-mono || true

# fzf: shell entegrasyonu (~/.fzf.bash) icin. .bashrc bu dosyayi source ediyor.
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
else
    git -C "$HOME/.fzf" pull --ff-only || true
fi
"$HOME/.fzf/install" --all --no-update-rc

# Neovim config
echo "Setting up Neovim config..."
NVIM_CONFIG_DIR="$HOME/.config/nvim"
mkdir -p "$NVIM_CONFIG_DIR"

if [ -e "$NVIM_CONFIG_DIR/init.lua" ] && ! cmp -s "$SCRIPT_DIR/init.lua" "$NVIM_CONFIG_DIR/init.lua"; then
    cp -a "$NVIM_CONFIG_DIR/init.lua" "$NVIM_CONFIG_DIR/init.lua.bak.$(date +%Y%m%d-%H%M%S)"
fi
cp "$SCRIPT_DIR/init.lua" "$NVIM_CONFIG_DIR/init.lua"

# lazy.nvim'i init.lua kendisi bootstrap ediyor (stdpath("data")/lazy/lazy.nvim),
# burada ayrica klonlamaya gerek yok. Eklentileri simdi kur:
nvim --headless "+Lazy! sync" +qa || true

echo "Neovim ortami hazir."

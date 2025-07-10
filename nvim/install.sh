#!/usr/bin/env bash

echo "🚀 Installing C/C++ dev env with Neovim"

# Paketler
echo "🔧 Installing system packages..."

sudo apt update
sudo apt install -y software-properties-common

# Resmi stable PPA ekle
sudo add-apt-repository ppa:neovim-ppa/stable

# Güncelle ve kur
sudo apt update
sudo apt install -y neovim clangd ripgrep fd-find cscope exuberant-ctags git xclip


if command -v rustc &>/dev/null; then
  cargo install fd-find
fi

# Neovim Lazy kur
echo "📦 Setting up Lazy.nvim..."
NVIM_CONFIG_DIR="$HOME/.config/nvim"
mkdir -p "$NVIM_CONFIG_DIR/lua"

# Lazy manager
git clone --filter=blob:none https://github.com/folke/lazy.nvim.git \
  "${NVIM_CONFIG_DIR}/lazy/lazy.nvim"
cp  init.lua ~/.config/nvim/init.lua


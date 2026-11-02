#!/usr/bin/env bash
# Neovim tabanli C/C++ gelistirme ortami

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/link.sh
source "$SCRIPT_DIR/../lib/link.sh"

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

# init.lua Neovim >= 0.11 ister (vim.lsp.enable). Daha eskiyse uyar; kurulum yine de devam eder.
if ! nvim --headless '+lua os.exit(vim.fn.has("nvim-0.11") == 1 and 0 or 1)' >/dev/null 2>&1; then
    echo "UYARI: kurulu Neovim 0.11'den eski; init.lua uyari verip yuklenmeyecek."
    echo "       Guncel surum icin: snap install nvim --classic veya resmi release arsivi."
fi

# tree-sitter CLI: nvim-treesitter (main dali) parser derlemek icin ister.
# Resmi paket (tree-sitter organizasyonu); kurulum betigi ikiliyi github.com/tree-sitter/tree-sitter
# release'inden indirir. Kurulmazsa nvim yine calisir, sadece treesitter vurgusu olmaz.
if ! command -v tree-sitter >/dev/null 2>&1; then
    if command -v npm >/dev/null 2>&1; then
        npm install -g tree-sitter-cli || echo "UYARI: tree-sitter-cli kurulamadi (npm -g izni?)."
    else
        echo "UYARI: npm yok, tree-sitter-cli kurulmadi (nvm kur ya da: cargo install --locked tree-sitter-cli)."
    fi
fi

# Neovim config
echo "Setting up Neovim config..."
NVIM_CONFIG_DIR="$HOME/.config/nvim"
mkdir -p "$NVIM_CONFIG_DIR"

# Sembolik bag: repo'daki init.lua'yi duzenlemek canli config'i de gunceller.
link_file "$SCRIPT_DIR/init.lua" "$NVIM_CONFIG_DIR/init.lua"

# lazy.nvim'i init.lua kendisi bootstrap ediyor (stdpath("data")/lazy/lazy.nvim),
# burada ayrica klonlamaya gerek yok. Eklentileri simdi kur:
nvim --headless "+Lazy! sync" +qa || true

echo "Neovim ortami hazir."

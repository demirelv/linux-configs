#!/bin/bash
# Klasik vim ortami (Vundle + .vimrc). Ana install.sh bunu cagirmaz; gerekirse elle calistir:
#   bash vim/install.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# vim + araclar (Ubuntu deposundaki surum yeterli, PPA gerekmiyor)
sudo apt-get update
sudo apt-get install -y vim silversearcher-ag ripgrep universal-ctags cscope git curl

# plugin manager: Vundle
if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"
fi

# fzf: shell entegrasyonu icin (.bashrc ~/.fzf.bash'i source ediyor)
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
fi
"$HOME/.fzf/install" --all --no-update-rc

# undo ve view dizinleri
mkdir -p "$HOME/.vim/undodir" "$HOME/.vim/view"

# .vimrc'yi kopyala (farkliysa yedek al)
if [ -e "$HOME/.vimrc" ] && ! cmp -s "$SCRIPT_DIR/.vimrc" "$HOME/.vimrc"; then
    cp -a "$HOME/.vimrc" "$HOME/.vimrc.bak.$(date +%Y%m%d-%H%M%S)"
fi
cp "$SCRIPT_DIR/.vimrc" "$HOME/.vimrc"

# Eklentileri kurmak icin: vim +PluginInstall +qall
# C dili completer icin (YouCompleteMe):
#   cd ~/.vim/bundle/YouCompleteMe/
#   python3 install.py --clangd-completer
#   veya C++ derleyicisi ile: CXX=/usr/bin/g++ python3 install.py --clangd-completer

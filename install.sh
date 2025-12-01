#!/bin/bash

# Dotfiles Installation Script
# Creates symlinks from dotfiles repo to their expected locations

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

echo "=== Dotfiles Installer ==="
echo "Dotfiles directory: $DOTFILES_DIR"

# Function to create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"

    if [ -e "$target" ] || [ -L "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        echo "  Backing up existing: $target -> $BACKUP_DIR/"
        mv "$target" "$BACKUP_DIR/"
    fi

    mkdir -p "$(dirname "$target")"
    ln -sf "$source" "$target"
    echo "  Linked: $target -> $source"
}

echo ""
echo "Installing configurations..."

# Aerospace
echo "[aerospace]"
create_symlink "$DOTFILES_DIR/aerospace/aerospace.toml" "$HOME/.config/aerospace/aerospace.toml"

# Alacritty
echo "[alacritty]"
create_symlink "$DOTFILES_DIR/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"

# Neovim
echo "[nvim]"
create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# Tmux
echo "[tmux]"
create_symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# Zsh
echo "[zsh]"
create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"

# SKHD
echo "[skhd]"
create_symlink "$DOTFILES_DIR/skhd/skhdrc" "$HOME/.config/skhd/skhdrc"

echo ""
echo "=== Installation complete! ==="
echo ""
echo "Next steps:"
echo "  1. Restart your terminal"
echo "  2. Install dependencies with: brew bundle (if Brewfile exists)"
echo "  3. For oh-my-zsh + powerlevel10k, run:"
echo "     sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
echo "     git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \${ZSH_CUSTOM:-\$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
echo ""
if [ -d "$BACKUP_DIR" ]; then
    echo "Backups saved to: $BACKUP_DIR"
fi

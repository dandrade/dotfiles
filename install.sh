#!/bin/bash

# Dotfiles Installation Script
# Symlinks configs from this repo to their expected locations.
# Idempotent: safe to re-run. Existing non-symlink files are backed up first.
#
# Usage:
#   ./install.sh            install (symlink) everything
#   ./install.sh --dry-run  show what would happen, touch nothing

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

DRY_RUN=0
[ "$1" = "--dry-run" ] && DRY_RUN=1

echo "=== Dotfiles Installer ==="
echo "Dotfiles directory: $DOTFILES_DIR"
[ "$DRY_RUN" = 1 ] && echo "(dry run — no changes will be made)"
echo ""

# link <source> <target>
# Creates target -> source symlink. Backs up an existing real file/dir.
# Skips if the correct symlink already exists. Never aborts the whole run.
link() {
    local source="$1"
    local target="$2"

    if [ ! -e "$source" ]; then
        echo "  SKIP  (source missing) $source"
        return 0
    fi

    # Already the correct symlink? Nothing to do.
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        echo "  OK    $target"
        return 0
    fi

    if [ "$DRY_RUN" = 1 ]; then
        if [ -e "$target" ] || [ -L "$target" ]; then
            echo "  WOULD back up + relink $target -> $source"
        else
            echo "  WOULD link $target -> $source"
        fi
        return 0
    fi

    # Back up anything currently at the target (real file, dir, or stale link).
    if [ -e "$target" ] || [ -L "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        echo "  backup: $target -> $BACKUP_DIR/"
        mv "$target" "$BACKUP_DIR/" 2>/dev/null || { echo "  ERROR backing up $target — skipping"; return 1; }
    fi

    mkdir -p "$(dirname "$target")"
    ln -sf "$source" "$target"
    echo "  linked: $target -> $source"
}

echo "Installing configurations..."

echo "[aerospace]"
link "$DOTFILES_DIR/aerospace/aerospace.toml" "$HOME/.config/aerospace/aerospace.toml"
link "$DOTFILES_DIR/aerospace/adjust-gaps.sh" "$HOME/.config/aerospace/adjust-gaps.sh"

echo "[ghostty]"
link "$DOTFILES_DIR/ghostty/config"  "$HOME/.config/ghostty/config"
link "$DOTFILES_DIR/ghostty/shaders" "$HOME/.config/ghostty/shaders"

echo "[nvim]"
link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

echo "[tmux]"
link "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
link "$DOTFILES_DIR/tmux-scripts/user_emoji.sh" "$HOME/.config/tmux/user_emoji.sh"

echo "[starship]"
link "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship/starship.toml"

echo "[sketchybar]"
link "$DOTFILES_DIR/sketchybar" "$HOME/.config/sketchybar"

echo "[skhd]"
link "$DOTFILES_DIR/skhd/skhdrc" "$HOME/.config/skhd/skhdrc"

echo "[zsh]"
link "$DOTFILES_DIR/zsh/.zshrc"    "$HOME/.zshrc"
link "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"

echo ""
echo "=== Installation complete! ==="

if [ "$DRY_RUN" = 1 ]; then
    echo "(dry run — nothing was changed)"
    exit 0
fi

echo ""
echo "Next steps:"
echo "  1. Install dependencies:"
echo "       brew bundle --file=$DOTFILES_DIR/Brewfile"
echo ""
echo "  2. Install oh-my-zsh:"
echo "       sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
echo ""
echo "  3. Install zsh plugins:"
echo "       git clone https://github.com/zsh-users/zsh-autosuggestions \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
echo "       git clone https://github.com/zsh-users/zsh-syntax-highlighting \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
echo ""
echo "  4. Install tmux plugins (inside tmux): prefix + I"
echo ""
echo "  5. Install atuin (shell history):"
echo "       curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh"
echo ""
echo "  6. Machine-specific PATH/secrets go in ~/.zshrc.local (git-ignored)."
echo ""
echo "  7. Restart your terminal."
echo ""
if [ -d "$BACKUP_DIR" ]; then
    echo "Backups saved to: $BACKUP_DIR"
fi

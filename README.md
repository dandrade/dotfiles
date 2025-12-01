# Dotfiles

Personal dotfiles for macOS development environment.

## Contents

- **aerospace** - Tiling window manager config
- **alacritty** - Terminal emulator config
- **nvim** - Neovim config (LazyVim)
- **tmux** - Terminal multiplexer config
- **zsh** - Shell config with oh-my-zsh + powerlevel10k
- **skhd** - Hotkey daemon config

## Installation

### Quick Install

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

### Install Dependencies (macOS)

```bash
# Install Homebrew first if needed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install all dependencies
brew bundle --file=~/dotfiles/Brewfile
```

### Oh-My-Zsh + Powerlevel10k

```bash
# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

## Backup

Old configs are automatically backed up to `~/.dotfiles_backup/` when running install.sh.

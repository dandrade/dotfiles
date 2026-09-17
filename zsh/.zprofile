# Homebrew (Apple Silicon). Must come first: everything below may depend on it.
eval "$(/opt/homebrew/bin/brew shellenv)"

# Kiro CLI
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.pre.zsh" ]] && \
  builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.pre.zsh"

# OrbStack: command-line tools and integration
source "$HOME/.orbstack/shell/init.zsh" 2>/dev/null || :

[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.post.zsh" ]] && \
  builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.post.zsh"

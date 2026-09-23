# ---------------------------------------------------------------------------
# oh-my-zsh
# ---------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"

plugins=(
  git
  brew
  common-aliases
  node
  npm
  yarn
  colored-man-pages
  colorize
  cp
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# common-aliases defines `duf`; drop it so the real duf(1) wins.
(( ${+aliases[duf]} )) && unalias duf

# ---------------------------------------------------------------------------
# Completions
# ---------------------------------------------------------------------------
if [ -d "$HOME/.zsh/completions" ]; then
  case ":$FPATH:" in
    *":$HOME/.zsh/completions:"*) ;;
    *) export FPATH="$HOME/.zsh/completions:$FPATH" ;;
  esac
fi

# ---------------------------------------------------------------------------
# PATH — prepend only if the directory exists (keeps this portable).
# Order matters: later entries win. Homebrew must beat /usr/local (Intel leftovers).
# ---------------------------------------------------------------------------
for _p in \
  "$HOME/.cargo/bin" \
  "$HOME/.orbstack/bin" \
  "$HOME/.yarn/bin" \
  "$HOME/.pub-cache/bin" \
  "$HOME/go/bin" \
  "$HOME/.local/bin" \
  "$HOME/.rbenv/bin" \
  "$HOME/.bun/bin" \
  "$HOME/.opencode/bin" \
  "$HOME/.console-ninja/.bin" \
  "$HOME/Library/pnpm" \
  "$HOME/development/flutter/bin" \
  "/opt/homebrew/opt/llvm/bin" \
  "/opt/homebrew/opt/imagemagick@6/bin" \
  "/opt/homebrew/opt/postgresql@17/bin" \
  "/Applications/Ghostty.app/Contents/MacOS" \
  "/opt/homebrew/bin" \
  "/opt/homebrew/sbin"; do
  [ -d "$_p" ] && case ":$PATH:" in *":$_p:"*) ;; *) export PATH="$_p:$PATH" ;; esac
done
unset _p

export PNPM_HOME="$HOME/Library/pnpm"
export BUN_INSTALL="$HOME/.bun"

# ---------------------------------------------------------------------------
# Build flags (readline + libffi, for native gem/python builds)
# ---------------------------------------------------------------------------
export LDFLAGS="-L/opt/homebrew/opt/readline/lib -L/opt/homebrew/opt/libffi/lib"
export CPPFLAGS="-I/opt/homebrew/opt/readline/include -I/opt/homebrew/opt/libffi/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/readline/lib/pkgconfig:/opt/homebrew/opt/libffi/lib/pkgconfig"
export optflags="-Wno-error=implicit-function-declaration"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3)"
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------
export XDG_CONFIG_HOME="$HOME/.config"
export JAVA_HOME="$(/usr/libexec/java_home -v 21 2>/dev/null)"
export BAT_THEME=Dracula
export CLAUDE_POWERLINE_THEME=rose-pine
export MAX_MCP_OUTPUT_TOKENS=1000000
export INFISICAL_API_URL="http://secrets.danielandrade.co"

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
alias ls='eza --icons'
alias la='eza --long --all --group --header --git --icons'
alias cat='bat'
alias vim=nvim
alias td="tmux detach"
alias ta="tmux attach-session"
alias lg='lazygit'
alias lz="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"
alias claude-mem='bun "$HOME/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'

# ---------------------------------------------------------------------------
# Version managers
# ---------------------------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

command -v rbenv >/dev/null && eval "$(rbenv init -)"

# ---------------------------------------------------------------------------
# Prompt & shell tools
# ---------------------------------------------------------------------------
# LS_COLORS is cached: regenerating it with vivid on every shell costs ~100ms.
# Refresh with: vivid generate snazzy > ~/.cache/ls_colors
_ls_colors_cache="$HOME/.cache/ls_colors"
if [ ! -f "$_ls_colors_cache" ] && command -v vivid >/dev/null; then
  mkdir -p "$HOME/.cache" && vivid generate snazzy > "$_ls_colors_cache"
fi
[ -f "$_ls_colors_cache" ] && export LS_COLORS="$(<"$_ls_colors_cache")"
unset _ls_colors_cache

command -v starship >/dev/null && eval "$(starship init zsh)"
command -v zoxide   >/dev/null && eval "$(zoxide init zsh)"
command -v fzf      >/dev/null && eval "$(fzf --zsh)"

[ -s "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"
command -v atuin >/dev/null && eval "$(atuin init zsh)"

[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
[ -f "$HOME/.config/broot/launcher/bash/br" ] && source "$HOME/.config/broot/launcher/bash/br"

# ---------------------------------------------------------------------------
# Machine-specific overrides (git-ignored). Anything with hardcoded absolute
# paths, per-machine tooling or secrets belongs in ~/.zshrc.local, not here.
# ---------------------------------------------------------------------------
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# bun completions
[ -s "/Users/dam/.bun/_bun" ] && source "/Users/dam/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

. "$HOME/.local/bin/env"

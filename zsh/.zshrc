# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"
if [[ ":$FPATH:" != *":/Users/dam/.zsh/completions:"* ]]; then export FPATH="/Users/dam/.zsh/completions:$FPATH"; fi
#[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
export ZSH="$HOME/.oh-my-zsh"

plugins=(
  git zsh-autosuggestions
  git
  brew
  common-aliases
  node
  npm
  yarn
  colored-man-pages
  colorize
  cp
  zsh-syntax-highlighting
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh
alias ls='eza --icons'
alias la='eza --long  --all --group --header --git --icons'
alias cat='bat'
alias vim=nvim
export LS_COLORS="$(vivid generate snazzy)"

export PATH=/Users/dam/mjml_bin/node_modules/.bin:$PATH
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

export LDFLAGS="-L/opt/homebrew/opt/readline/lib:$LDFLAGS"
export CPPFLAGS="-I/opt/homebrew/opt/readline/include:$CPPFLAGS"
export PKG_CONFIG_PATH="/opt/homebrew/opt/readline/lib/pkgconfig:$PKG_CONFIG_PATH"
export optflags="-Wno-error=implicit-function-declaration"
export LDFLAGS="-L/opt/homebrew/opt/libffi/lib:$LDFLAGS"
export CPPFLAGS="-I/opt/homebrew/opt/libffi/include:$CPPFLAGS"
export PKG_CONFIG_PATH="/opt/homebrew/opt/libffi/lib/pkgconfig:$PKG_CONFIG_PATH"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/dam/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/dam/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/dam/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/dam/google-cloud-sdk/completion.zsh.inc'; fi


# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/Users/dam/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export BAT_THEME=Dracula

# ~/.zshrc
export PATH=/Users/dam/.local/bin:$PATH

PATH=~/.console-ninja/.bin:$PATH
export PATH="/opt/homebrew/opt/imagemagick@6/bin:$PATH"
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
eval "$(starship init zsh)"
eval "$(rbenv init -)"


eval "$(fzf --zsh)"
export INFISICAL_API_URL="http://secrets.danielandrade.co"
export PATH=$HOME/development/flutter/bin:$PATH

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /Users/dam/.dart-cli-completion/zsh-config.zsh ]] && . /Users/dam/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

#export PATH="$PATH":"$HOME/.pub-cache/bin" 
#export FVM_CACHE_PATH="/Users/dam/.fvm/versions"
# nuevo java
#export JAVA_HOME=$(/usr/libexec/java_home -v 17)

export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home


export XDG_CONFIG_HOME="$HOME/.config"

eval "$(zoxide init zsh)"

# Added by Windsurf
nvm use 24.6.0
export CLAUDE_POWERLINE_THEME=rose-pine
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"alias td="tmux detach"
alias ta="tmux attach-session"
alias lz="fzf --preview  'bat --style=numbers --color=always --line-range :500 {}'"
alias lg='lazygit'
source /Users/dam/.config/broot/launcher/bash/br

# bun completions
[ -s "/Users/dam/.bun/_bun" ] && source "/Users/dam/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"

# Brewfile — curated set for provisioning a new machine.
#
# Derived from `brew leaves --installed-on-request`, not from the full install
# list: Homebrew resolves dependencies on its own. Brewfile.full holds the
# complete dump of the old machine for reference.
#
# Validate with:  brew bundle check --file=~/dotfiles/Brewfile --verbose
# Install with:   brew bundle --file=~/dotfiles/Brewfile
#
# Fragile third-party taps live in Brewfile.optional so a dead tap can't abort
# this file.
#
# Note: zsh is intentionally absent — macOS ships 5.9, same as Homebrew.
# yarn is intentionally absent — use `corepack enable` (bundled with Node).

# Homebrew 7 refuses to load formulae/casks from untrusted third-party taps.
# bootstrap.sh runs `brew trust` for these before `brew bundle`.
tap "felixkratz/formulae"
tap "nikitabobko/tap"

# --- Shell & terminal -------------------------------------------------------
brew "tmux"
brew "neovim"
brew "starship"
brew "atuin"
brew "zoxide"
brew "fzf"
brew "vivid"

# --- Core CLI ---------------------------------------------------------------
brew "git"
brew "gh"
brew "ghq"
brew "ripgrep"
brew "fd"
brew "bat"
brew "eza"
brew "duf"
brew "procs"
brew "jq"
brew "wget"
brew "curl"
brew "coreutils"
brew "make"
brew "cmake"
brew "automake"
brew "sevenzip"
brew "watch"
brew "tokei"
brew "glow"
brew "broot"
brew "btop"

# --- Git & containers -------------------------------------------------------
brew "lazygit"
brew "lazydocker"

# --- Languages & runtimes ---------------------------------------------------
brew "node"
brew "rbenv"
brew "pipx"
brew "elixir"
brew "openjdk@17"
brew "jenv"

# --- Databases --------------------------------------------------------------
# One version each. Prior machine accumulated postgresql@14/15/16/17 and four
# MySQL formulae; the shell config now points at @17.
brew "postgresql@17"
brew "postgis"
brew "mysql-client@8.4"
brew "redis"

# --- Cloud & infra ----------------------------------------------------------
brew "terraform"
# The old machine had aws in /usr/local/bin (Intel-era installer); install it
# from Homebrew here so it lives under /opt/homebrew like everything else.
brew "awscli"
brew "aws-sam-cli"
brew "saml2aws"
brew "cloudflared"
brew "wireguard-tools"
brew "sshuttle"
brew "socat"
brew "telnet"
brew "nmap"

# --- Networking & testing ---------------------------------------------------
brew "httpie"
brew "k6"
brew "jmeter"
brew "watchman"

# --- Media & graphics -------------------------------------------------------
brew "imagemagick"
brew "vips"
brew "graphviz"
brew "silicon"

# --- Go toolchain -----------------------------------------------------------
brew "gopls"
brew "gofumpt"
brew "golines"
brew "gomodifytags"
brew "gotests"
brew "delve"

# --- Task management --------------------------------------------------------
brew "taskwarrior-tui"
brew "timewarrior"

# --- Fun --------------------------------------------------------------------
brew "figlet"
brew "neofetch"

# --- Window management (macOS) ---------------------------------------------
cask "nikitabobko/tap/aerospace"
brew "felixkratz/formulae/sketchybar"
# skhd is not in core — it comes from a third-party tap. See Brewfile.optional.

# --- Applications -----------------------------------------------------------
cask "ghostty"
cask "orbstack"
cask "claude-code"
cask "gcloud-cli"
cask "zulu@21"
cask "maccy"
cask "jordanbaird-ice"
cask "stats"
cask "shortcat"
cask "ngrok"
cask "devtoys"
cask "upscayl"
cask "pomotroid"
# pingplace comes from notwadegrimridge/brew — see Brewfile.optional

# --- Mobile development -----------------------------------------------------
cask "android-platform-tools"
cask "chromedriver"
cask "minisim"
cask "session-manager-plugin"

# --- Fonts ------------------------------------------------------------------
# The homebrew/cask-fonts tap was removed in 2024; fonts now live in
# homebrew/cask and need no tap. The old machine had 67 nerd fonts installed
# one by one, yet ghostty/config asks for "JetBrainsMono Nerd Font" — which
# was NOT among them, so the terminal was silently falling back.
cask "font-jetbrains-mono-nerd-font"
cask "font-symbols-only-nerd-font"

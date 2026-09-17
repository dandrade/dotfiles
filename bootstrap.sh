#!/bin/bash
# Provision a new Mac from this repo.
#
#   ./bootstrap.sh              run everything
#   ./bootstrap.sh --dry-run    show what would happen, change nothing
#
# Idempotent: every step guards on what is already present, so re-running is
# safe and is the intended way to resume after a failure.
#
# Deliberately does NOT handle secrets or repos — those need SSH keys and your
# judgement. The final summary lists them as manual steps.

set -uo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
REPO_URL="https://github.com/dandrade/dotfiles.git"
DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

FAILED=()

step() { echo ""; echo "=== $* ==="; }
run()  {
  if [ "$DRY_RUN" = 1 ]; then echo "  WOULD: $*"; return 0; fi
  "$@"
}
note() { echo "  $*"; }
fail() { echo "  FAILED: $*"; FAILED+=("$*"); }

[ "$DRY_RUN" = 1 ] && echo "(dry run — nothing will be changed)"

# --- 1. Xcode Command Line Tools -------------------------------------------
# Everything below needs git, which ships here.
step "Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
  note "already installed"
else
  if [ "$DRY_RUN" = 1 ]; then
    note "WOULD: xcode-select --install"
  else
    xcode-select --install
    echo ""
    echo "  Finish the GUI installer, then re-run this script."
    exit 1
  fi
fi

# --- 2. Homebrew ------------------------------------------------------------
step "Homebrew"
if command -v brew >/dev/null 2>&1; then
  note "already installed: $(brew --version | head -1)"
else
  if [ "$DRY_RUN" = 1 ]; then
    note "WOULD: install Homebrew"
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
      || { fail "Homebrew install"; exit 1; }
  fi
fi
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# --- 3. Clone the repo ------------------------------------------------------
# Over HTTPS: SSH keys are restored later, by hand.
step "dotfiles repo"
if [ -d "$DOTFILES/.git" ]; then
  note "already present: $DOTFILES"
else
  run git clone "$REPO_URL" "$DOTFILES" || fail "clone dotfiles"
fi

# --- 4. Homebrew packages ---------------------------------------------------
# Homebrew 7 refuses formulae from untrusted third-party taps, so trust them
# before bundling or every tapped package fails.
step "Homebrew packages"
if [ "$DRY_RUN" = 1 ]; then
  note "WOULD: brew trust + brew bundle (Brewfile, then Brewfile.optional)"
else
  for t in felixkratz/formulae nikitabobko/tap; do
    brew tap "$t" >/dev/null 2>&1
    brew trust "$t" >/dev/null 2>&1 || note "could not trust $t (continuing)"
  done

  note "installing Brewfile (this takes a while)..."
  brew bundle --file="$DOTFILES/Brewfile" || fail "brew bundle (Brewfile)"

  # Optional set: third-party taps that may have disappeared. Never fatal.
  if [ -f "$DOTFILES/Brewfile.optional" ]; then
    note "installing Brewfile.optional (failures here are not fatal)..."
    for t in dart-lang/dart leoafarias/fvm heroku/brew stripe/stripe-cli \
             supabase/tap infisical/get-cli facebook/fb \
             notwadegrimridge/brew koekeishiya/formulae; do
      brew tap "$t" >/dev/null 2>&1 && brew trust "$t" >/dev/null 2>&1
    done
    brew bundle --file="$DOTFILES/Brewfile.optional" || note "some optional packages failed (expected)"
  fi
fi

# --- 5. Symlink configs -----------------------------------------------------
# Before the version managers: ~/.zshrc becomes a symlink into the repo here,
# and nvm/rbenv installers append to it. Doing this first means their edits
# land in a file we then check with `git status` (step 10).
step "symlink configs"
if [ -x "$DOTFILES/install.sh" ]; then
  if [ "$DRY_RUN" = 1 ]; then
    "$DOTFILES/install.sh" --dry-run
  else
    "$DOTFILES/install.sh" || fail "install.sh"
  fi
else
  fail "install.sh not found or not executable"
fi

# --- 6. Version managers ----------------------------------------------------
step "version managers"
if [ -d "$HOME/.nvm" ]; then
  note "nvm already installed"
else
  run mkdir -p "$HOME/.nvm"
  if [ "$DRY_RUN" = 0 ]; then
    export NVM_DIR="$HOME/.nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash \
      || fail "nvm install"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install 24 && nvm alias default 24 || fail "node 24"
    # yarn via corepack, not a global npm install (the old machine had a 2022
    # symlink in /usr/local/bin).
    corepack enable 2>/dev/null || note "corepack enable failed (non-fatal)"
  else
    note "WOULD: install nvm + node 24 + corepack enable"
  fi
fi

if command -v rbenv >/dev/null 2>&1; then
  if [ "$DRY_RUN" = 0 ]; then
    rbenv install -s 3.4.4 && rbenv global 3.4.4 || note "ruby 3.4.4 install failed"
  else
    note "WOULD: rbenv install 3.4.4"
  fi
fi

[ -d "$HOME/.bun" ] || { [ "$DRY_RUN" = 1 ] && note "WOULD: install bun" || \
  curl -fsSL https://bun.sh/install | bash || fail "bun"; }

command -v uv >/dev/null 2>&1 || { [ "$DRY_RUN" = 1 ] && note "WOULD: install uv" || \
  curl -LsSf https://astral.sh/uv/install.sh | sh || fail "uv"; }

# --- 7. oh-my-zsh + plugins -------------------------------------------------
# .zshrc sources these; without them every new shell errors.
step "oh-my-zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  note "already installed"
elif [ "$DRY_RUN" = 1 ]; then
  note "WOULD: install oh-my-zsh + plugins"
else
  # --unattended: do not chsh or start a new shell.
  # --keep-zshrc: never touch ~/.zshrc, which is a symlink into the repo.
  KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended --keep-zshrc || fail "oh-my-zsh"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
for p in zsh-autosuggestions zsh-syntax-highlighting; do
  if [ -d "$ZSH_CUSTOM/plugins/$p" ]; then
    note "$p already present"
  else
    run git clone --depth=1 "https://github.com/zsh-users/$p" "$ZSH_CUSTOM/plugins/$p" \
      || fail "plugin $p"
  fi
done

# --- 8. atuin ---------------------------------------------------------------
step "atuin"
if command -v atuin >/dev/null 2>&1 || [ -d "$HOME/.atuin" ]; then
  note "already installed"
else
  run brew install atuin || fail "atuin"
fi

# --- 9. tmux plugin manager -------------------------------------------------
step "tmux plugin manager"
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  note "already installed"
else
  run git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" \
    || fail "tpm"
fi

# --- 10. Did anything write into the repo? ----------------------------------
# Installers love appending to ~/.zshrc, which is now a symlink into the repo.
step "repo cleanliness"
if [ "$DRY_RUN" = 0 ] && [ -d "$DOTFILES/.git" ]; then
  if [ -z "$(git -C "$DOTFILES" status --porcelain)" ]; then
    note "clean — nothing wrote into the repo"
  else
    note "the repo was modified during bootstrap:"
    git -C "$DOTFILES" status --short | sed 's/^/    /'
    note "review it; move machine-specific lines to ~/.zshrc.local"
  fi
fi

# --- Summary ----------------------------------------------------------------
step "Summary"
if [ ${#FAILED[@]} -gt 0 ]; then
  echo "  Failed steps:"
  printf '    - %s\n' "${FAILED[@]}"
  echo ""
  echo "  Fix the cause and re-run — this script is idempotent."
else
  echo "  All automated steps completed."
fi

cat <<'MANUAL'

  Manual steps (they need your keys or your judgement):

  1. Secrets — from the old machine:
       ./scripts/export-secrets.sh          # old
       ./scripts/import-secrets.sh <file>   # new
  2. Re-authenticate: gh auth login, gcloud auth login, atuin login
  3. Repos:   ./scripts/clone-repos.sh      (needs SSH from step 1)
  4. nvim:    open it once so lazy.nvim restores from lazy-lock.json
  5. tmux:    start it, then prefix + I
  6. Verify:  ./scripts/verify.sh
MANUAL

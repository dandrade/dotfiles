#!/bin/bash
# Check that a machine provisioned by bootstrap.sh actually matches intent.
#
#   ./verify.sh                 run all checks
#   ./verify.sh --baseline      write a baseline (run on the OLD machine first)
#
# Exit code is the number of failed checks, so CI or a shell test can use it.

set -uo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
BASELINE_DIR="$HOME/migracion/baseline"
PASS=0; FAIL=0; WARN=0

ok()   { echo "  PASS  $*"; PASS=$((PASS+1)); }
bad()  { echo "  FAIL  $*"; FAIL=$((FAIL+1)); }
warn() { echo "  WARN  $*"; WARN=$((WARN+1)); }
section() { echo ""; echo "=== $* ==="; }

# --- Baseline mode: snapshot the old machine --------------------------------
if [ "${1:-}" = "--baseline" ]; then
  mkdir -p "$BASELINE_DIR"
  brew leaves --installed-on-request 2>/dev/null | sort > "$BASELINE_DIR/leaves.txt"
  brew list --cask 2>/dev/null | sort > "$BASELINE_DIR/casks.txt"
  # Every command reachable on PATH — the real measure of "does it feel the same".
  echo "$PATH" | tr ':' '\n' | while read -r d; do
    [ -d "$d" ] && ls "$d" 2>/dev/null
  done | sort -u > "$BASELINE_DIR/commands.txt"
  command -v ghq >/dev/null && ghq list 2>/dev/null | sort > "$BASELINE_DIR/repos.txt"
  echo "Baseline written to $BASELINE_DIR:"
  wc -l "$BASELINE_DIR"/*.txt 2>/dev/null | sed 's/^/  /'
  echo ""
  echo "Copy this directory to the new machine, then run verify.sh there."
  exit 0
fi

echo "=== Verification: $(scutil --get ComputerName 2>/dev/null || hostname) ==="

# --- 1. Symlinks ------------------------------------------------------------
# The root cause of the original problem: these were real files, so the repo
# silently drifted from the system.
section "Symlinks"
for t in "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.zshenv" "$HOME/.tmux.conf" \
         "$HOME/.config/nvim" "$HOME/.config/ghostty/config" \
         "$HOME/.config/starship/starship.toml" "$HOME/.config/sketchybar" \
         "$HOME/.config/skhd/skhdrc" "$HOME/.config/aerospace/aerospace.toml"; do
  if [ -L "$t" ]; then ok "${t/#$HOME/~}"
  elif [ -e "$t" ]; then bad "${t/#$HOME/~} is a real file, not a symlink"
  else bad "${t/#$HOME/~} missing"; fi
done

# --- 2. PATH ----------------------------------------------------------------
# Measure a fresh login shell, not this process: when verify.sh is launched
# from an old session, $PATH carries whatever that session accumulated, and
# every check below would report the parent's problems instead of the config's.
section "PATH"
CLEAN_PATH=$(env -i HOME="$HOME" TERM="${TERM:-xterm}" /bin/zsh -l -i -c 'echo $PATH' 2>/dev/null | tail -1)
[ -z "$CLEAN_PATH" ] && CLEAN_PATH="$PATH"
dup=$(echo "$CLEAN_PATH" | tr ':' '\n' | sort | uniq -d)
[ -z "$dup" ] && ok "no duplicates" || { bad "duplicate entries:"; echo "$dup" | sed 's/^/          /'; }

# /usr/local ahead of /opt/homebrew is what made yarn and aws resolve to
# Intel-era installs on the old machine.
hb=$(echo "$CLEAN_PATH" | tr ':' '\n' | grep -n '^/opt/homebrew/bin$' | head -1 | cut -d: -f1)
ul=$(echo "$CLEAN_PATH" | tr ':' '\n' | grep -n '^/usr/local/bin$'    | head -1 | cut -d: -f1)
if [ -n "$hb" ] && [ -n "$ul" ]; then
  [ "$hb" -lt "$ul" ] && ok "/opt/homebrew/bin precedes /usr/local/bin" \
                      || bad "/usr/local/bin precedes /opt/homebrew/bin"
elif [ -n "$hb" ]; then ok "/opt/homebrew/bin present, no /usr/local/bin"
else bad "/opt/homebrew/bin not on PATH"; fi

# --- 3. Command resolution --------------------------------------------------
section "Command resolution"
# Resolve against the clean login PATH, for the same reason as above.
check_from() {  # check_from <cmd> <expected-prefix>
  local p; p=$(PATH="$CLEAN_PATH" command -v "$1" 2>/dev/null)
  [ -z "$p" ] && { bad "$1 not found"; return; }
  case "$p" in $2*) ok "$1 -> $p";; *) bad "$1 -> $p (expected $2*)";; esac
}
check_from git /opt/homebrew
check_from bat /opt/homebrew
check_from eza /opt/homebrew
check_from starship /opt/homebrew

# yarn should come from corepack (inside the nvm tree), never /usr/local.
yarn_path=$(PATH="$CLEAN_PATH" command -v yarn 2>/dev/null)
if [ -n "$yarn_path" ]; then
  case "$yarn_path" in
    /usr/local/*) bad "yarn -> $yarn_path (Intel-era global install)";;
    *) ok "yarn -> $yarn_path";;
  esac
else
  warn "yarn not found (fine — corepack provides it per project)"
fi

# --- 4. Shell startup -------------------------------------------------------
section "Shell startup"
err=$(zsh -i -c 'exit' 2>&1 | grep -viE "can't change option: zle" | grep -v '^$')
[ -z "$err" ] && ok "no errors" || { bad "errors on startup:"; echo "$err" | sed 's/^/          /'; }

for a in td ta lg claude-mem; do
  zsh -i -c "alias $a" >/dev/null 2>&1 && ok "alias $a" || bad "alias $a missing"
done

# duf must be the binary, not the alias common-aliases defines.
if zsh -i -c 'alias duf' >/dev/null 2>&1; then
  bad "duf is still an alias (should be the binary)"
else
  ok "duf is not aliased"
fi

# --- 5. Brewfile ------------------------------------------------------------
section "Brewfile"
if [ -f "$DOTFILES/Brewfile" ]; then
  missing=0
  while read -r f; do
    case "$f" in */*) continue;; esac
    brew list --formula --versions "$f" >/dev/null 2>&1 || { echo "          missing formula: $f"; missing=$((missing+1)); }
  done < <(grep -E '^brew "' "$DOTFILES/Brewfile" | sed -E 's/^brew "([^"]+)".*/\1/')
  while read -r c; do
    case "$c" in */*) continue;; esac
    brew list --cask --versions "$c" >/dev/null 2>&1 || { echo "          missing cask: $c"; missing=$((missing+1)); }
  done < <(grep -E '^cask "' "$DOTFILES/Brewfile" | sed -E 's/^cask "([^"]+)".*/\1/')
  [ "$missing" = 0 ] && ok "all packages installed" || bad "$missing package(s) missing"
else
  bad "Brewfile not found"
fi

# --- 6. Repo cleanliness ----------------------------------------------------
section "Dotfiles repo"
if [ -d "$DOTFILES/.git" ]; then
  if [ -z "$(git -C "$DOTFILES" status --porcelain)" ]; then
    ok "clean working tree"
  else
    warn "repo has uncommitted changes:"
    git -C "$DOTFILES" status --short | sed 's/^/          /'
  fi
fi

# --- 7. External and absolute paths -----------------------------------------
# Two ways a tracked file stops being portable:
#  - sourcing something outside the repo: works only where that path happens to
#    exist. sketchybar lost its colorscheme this way, sourcing a palette from
#    ~/github/dotfiles-latest, which was never part of the repo.
#  - a hardcoded /Users/<name> path: breaks under any other account. Installers
#    reintroduce these by appending to ~/.zshrc, which is a symlink into here.
section "External and absolute paths"
ext=$(grep -rnE '^[^#]*\b(source|\.)[[:space:]]+"?\$\{?HOME\}?/(github|Develop|Documents|Downloads)/' \
        "$DOTFILES" --include='*.sh' --include='.zsh*' 2>/dev/null | grep -v '/\.git/' || true)
[ -z "$ext" ] && ok "nothing sources outside the repo" || {
  bad "tracked files depend on paths outside the repo:"; echo "$ext" | sed 's/^/          /'; }

abs=$(grep -rnE '^[^#]*/Users/[a-z]' "$DOTFILES" \
        --include='*.sh' --include='.zsh*' --include='*.toml' 2>/dev/null \
      | grep -v '/\.git/' | grep -vE '\.zshrc\.local' || true)
[ -z "$abs" ] && ok "no hardcoded /Users/<name> paths" || {
  bad "tracked files hardcode a user path (use \$HOME):"; echo "$abs" | sed 's/^/          /'; }

# ghostty/config names a font; on the old machine it asked for one of the 67
# --- 8. Fonts ---------------------------------------------------------------
# installed nerd fonts that was not actually among them.
section "Fonts"
if [ -f "$DOTFILES/ghostty/config" ]; then
  font=$(grep -E '^font-family' "$DOTFILES/ghostty/config" | head -1 | sed -E 's/.*= *//')
  if [ -n "$font" ]; then
    if system_profiler SPFontsDataType 2>/dev/null | grep -qi "${font%% *}"; then
      ok "ghostty font present: $font"
    else
      warn "ghostty font may be missing: $font"
    fi
  fi
fi

# --- 9. Compare against the baseline ---------------------------------------
section "Baseline comparison"
if [ -f "$BASELINE_DIR/commands.txt" ]; then
  echo "$CLEAN_PATH" | tr ':' '\n' | while read -r d; do
    [ -d "$d" ] && ls "$d" 2>/dev/null
  done | sort -u > /tmp/verify-commands.txt
  gone=$(comm -23 "$BASELINE_DIR/commands.txt" /tmp/verify-commands.txt | wc -l | tr -d ' ')
  if [ "$gone" = 0 ]; then
    ok "every command from the baseline is present"
  else
    warn "$gone command(s) from the old machine are absent:"
    comm -23 "$BASELINE_DIR/commands.txt" /tmp/verify-commands.txt | head -25 | sed 's/^/          /'
    echo "          (many are deliberate drops — review the list)"
  fi
  rm -f /tmp/verify-commands.txt
else
  warn "no baseline — run './verify.sh --baseline' on the old machine first"
fi

# --- 10. Connectivity --------------------------------------------------------
section "Connectivity"
ssh -o BatchMode=yes -o ConnectTimeout=5 -T git@github.com 2>&1 | grep -q "successfully authenticated" \
  && ok "github.com SSH" || warn "github.com SSH not working (run gh auth login / restore keys)"
ssh -o BatchMode=yes -o ConnectTimeout=5 -T git@bitbucket.org 2>&1 | grep -qiE "logged in|authenticated" \
  && ok "bitbucket.org SSH" || warn "bitbucket.org SSH not working (needed for the nova repo)"

# --- Summary ----------------------------------------------------------------
echo ""
echo "=== $PASS passed, $FAIL failed, $WARN warnings ==="
[ "$FAIL" -gt 0 ] && echo "Fix the failures above, then re-run."
exit "$FAIL"

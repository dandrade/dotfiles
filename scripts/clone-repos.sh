#!/bin/bash
# Clone every repo listed in repos.tsv using ghq, then lay out per-client
# symlinks so the old ~/Develop/<Client>/<repo> paths still work.
#
#   ./clone-repos.sh              clone everything
#   ./clone-repos.sh --dry-run    show what would happen
#   ./clone-repos.sh --client W2M clone only one client
#
# Requires SSH keys (run import-secrets.sh first) — most remotes are SSH.
# Idempotent: ghq fetches instead of failing when a repo is already there,
# and a failing repo never aborts the run.
#
# ghq stores everything under ~/ghq/<host>/<org>/<repo>, which flattens the
# per-client grouping. The symlinks in ~/Clientes/<Client>/ restore it, so
# both `ghq list | fzf` and the familiar paths work.

set -uo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
MANIFEST="${MANIFEST:-$DOTFILES/repos.tsv}"
CLIENT_ROOT="${CLIENT_ROOT:-$HOME/Clientes}"
DRY_RUN=0
ONLY_CLIENT=""

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift;;
    --client)  ONLY_CLIENT="${2:-}"; shift 2;;
    *) echo "Unknown option: $1"; exit 1;;
  esac
done

[ -f "$MANIFEST" ] || { echo "ERROR: manifest not found: $MANIFEST"; exit 1; }
command -v ghq >/dev/null 2>&1 || { echo "ERROR: ghq not installed (brew install ghq)"; exit 1; }

GHQ_ROOT="$(git config --get ghq.root 2>/dev/null || echo "$HOME/ghq")"

echo "=== Cloning repositories ==="
echo "Manifest: $MANIFEST"
echo "ghq root: $GHQ_ROOT"
[ -n "$ONLY_CLIENT" ] && echo "Client:   $ONLY_CLIENT"
[ "$DRY_RUN" = 1 ] && echo "(dry run — nothing will be cloned)"
echo ""

OK=0; SKIP=0; FAILED=()

# local_path_for <remote> — where ghq puts (or already put) this remote.
local_path_for() {
  local remote="$1" host path
  case "$remote" in
    *://*)
      host=$(echo "$remote" | sed -E 's#^[a-z]+://([^/@]*@)?([^/]+)/.*#\2#')
      path=$(echo "$remote" | sed -E 's#^[a-z]+://([^/@]*@)?[^/]+/##')
      ;;
    *@*:*)
      host=$(echo "$remote" | sed -E 's#^[^@]+@([^:]+):.*#\1#')
      path=$(echo "$remote" | sed -E 's#^[^@]+@[^:]+:##')
      ;;
    *) return 1;;
  esac
  path="${path%.git}"
  echo "$GHQ_ROOT/$host/$path"
}

while IFS=$'\t' read -r remote client notes; do
  [ -z "${remote:-}" ] && continue
  [ "$remote" = "remote" ] && continue              # header
  case "$remote" in \#*) continue;; esac            # comment
  [ -n "$ONLY_CLIENT" ] && [ "$client" != "$ONLY_CLIENT" ] && continue

  target=$(local_path_for "$remote") || { echo "  ?? unparseable remote: $remote"; FAILED+=("$remote"); continue; }

  if [ -d "$target/.git" ]; then
    echo "  ++ $client/$(basename "$target") (already cloned)"
    SKIP=$((SKIP+1))
  elif [ "$DRY_RUN" = 1 ]; then
    echo "  -> WOULD clone $remote"
    echo "       into $target"
    OK=$((OK+1))
  else
    echo "  -> $remote"
    if ghq get "$remote" >/dev/null 2>&1; then
      echo "       cloned into $target"
      OK=$((OK+1))
    else
      echo "       FAILED (no access, moved, or deleted)"
      FAILED+=("$remote")
      continue
    fi
  fi

  # Per-client symlink, so ~/Clientes/CocoBongo/nova keeps working.
  if [ -n "${client:-}" ] && [ -d "$target" -o "$DRY_RUN" = 1 ]; then
    link="$CLIENT_ROOT/$client/$(basename "$target")"
    if [ "$DRY_RUN" = 1 ]; then
      echo "       WOULD link $link"
    else
      mkdir -p "$CLIENT_ROOT/$client"
      ln -sfn "$target" "$link"
    fi
  fi

  # Worktrees are noted in the manifest but not recreated: they carry
  # branch-specific state that is yours to place.
  [ -n "${notes:-}" ] && echo "       note: $notes"
done < "$MANIFEST"

echo ""
echo "=== Summary ==="
echo "  cloned:  $OK"
echo "  present: $SKIP"
if [ ${#FAILED[@]} -gt 0 ]; then
  echo "  failed:  ${#FAILED[@]}"
  printf '    - %s\n' "${FAILED[@]}"
  echo ""
  echo "  Usually means no SSH access yet, or the repo moved. Check with:"
  echo "    ssh -T git@github.com && ssh -T git@bitbucket.org"
fi

if [ "$DRY_RUN" = 0 ] && [ "$OK" -gt 0 ]; then
  cat <<EOF

  Per-client symlinks: $CLIENT_ROOT/
  Browse with:         ghq list | fzf
EOF
fi

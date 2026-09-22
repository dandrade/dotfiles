#!/bin/bash
# Export secrets from the old machine into a single encrypted archive.
#
#   ./export-secrets.sh [output-dir]      # default: ~/migracion
#
# Produces <output-dir>/secretos-<date>.tar.gz.gpg, encrypted with a passphrase
# you choose. Transfer it over a cable or the local network, never via an
# unencrypted cloud folder, and run import-secrets.sh on the new machine.
#
# Nothing here belongs in git. The repo only carries this script.

set -uo pipefail

OUT_DIR="${1:-$HOME/migracion}"
STAMP="$(date +%Y%m%d_%H%M%S)"
STAGE="$(mktemp -d)"
ARCHIVE="$OUT_DIR/secretos-$STAMP.tar.gz.gpg"

cleanup() { rm -rf "$STAGE"; }
trap cleanup EXIT

command -v gpg >/dev/null || { echo "ERROR: gpg not found (brew install gnupg)"; exit 1; }
mkdir -p "$OUT_DIR"

echo "=== Exporting secrets ==="
echo "Staging: $STAGE"
echo ""

# --- SSH --------------------------------------------------------------------
if [ -d "$HOME/.ssh" ]; then
  mkdir -p "$STAGE/ssh"
  # Copy keys, config and known_hosts; skip sockets and the agent directory.
  find "$HOME/.ssh" -maxdepth 1 -type f -exec cp {} "$STAGE/ssh/" \;
  echo "  ssh:    $(ls -1 "$STAGE/ssh" | wc -l | tr -d ' ') files"
fi

# --- AWS --------------------------------------------------------------------
if [ -d "$HOME/.aws" ]; then
  mkdir -p "$STAGE/aws"
  for f in config credentials; do
    [ -f "$HOME/.aws/$f" ] && cp "$HOME/.aws/$f" "$STAGE/aws/"
  done
  # .bak files are deliberately skipped.
  echo "  aws:    $(ls -1 "$STAGE/aws" 2>/dev/null | wc -l | tr -d ' ') files"
fi

# --- GPG --------------------------------------------------------------------
if [ -d "$HOME/.gnupg" ]; then
  mkdir -p "$STAGE/gnupg"
  if gpg --list-secret-keys >/dev/null 2>&1; then
    gpg --export-secret-keys --armor > "$STAGE/gnupg/secret-keys.asc" 2>/dev/null
    gpg --export --armor            > "$STAGE/gnupg/public-keys.asc" 2>/dev/null
    gpg --export-ownertrust         > "$STAGE/gnupg/ownertrust.txt"  2>/dev/null
    echo "  gnupg:  keys exported"
  else
    echo "  gnupg:  no secret keys found, skipping"
  fi
fi

# --- Machine-specific shell config ------------------------------------------
[ -f "$HOME/.zshrc.local" ] && { cp "$HOME/.zshrc.local" "$STAGE/"; echo "  zshrc.local: yes"; }
[ -f "$HOME/.gitconfig.local" ] && cp "$HOME/.gitconfig.local" "$STAGE/"

# --- Manifest ---------------------------------------------------------------
{
  echo "Exported: $(date)"
  echo "From:     $(scutil --get ComputerName 2>/dev/null || hostname)"
  echo ""
  echo "Contents:"
  find "$STAGE" -type f | sed "s|$STAGE|  .|"
} > "$STAGE/MANIFEST.txt"

# --- Encrypt ----------------------------------------------------------------
echo ""
echo "Encrypting (you will be asked for a passphrase — remember it)..."
# --pinentry-mode loopback + GPG_TTY: without these gpg cannot prompt when
# stdin is not a terminal (over ssh, or from a non-interactive shell) and
# fails with "Inappropriate ioctl for device".
export GPG_TTY="${GPG_TTY:-$(tty 2>/dev/null)}"
tar czf - -C "$STAGE" . | \
  gpg --symmetric --cipher-algo AES256 --pinentry-mode loopback -o "$ARCHIVE"

if [ -f "$ARCHIVE" ]; then
  echo ""
  echo "=== Done ==="
  echo "  $ARCHIVE  ($(du -h "$ARCHIVE" | cut -f1))"
  echo ""
  echo "Next:"
  echo "  1. Copy it to the new machine over a cable or the local network."
  echo "  2. Run import-secrets.sh there."
  echo "  3. Delete the archive from both machines once done:"
  echo "       rm -P '$ARCHIVE'"
else
  echo "ERROR: encryption failed"; exit 1
fi

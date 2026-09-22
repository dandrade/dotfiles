#!/bin/bash
# Restore secrets on the new machine from export-secrets.sh output.
#
#   ./import-secrets.sh ~/secretos-20260917_143000.tar.gz.gpg
#
# Existing files are backed up before anything is overwritten. Permissions are
# set explicitly: ssh refuses keys that are group- or world-readable, which is
# the usual reason a migrated key "stops working".

set -uo pipefail

ARCHIVE="${1:-}"
[ -z "$ARCHIVE" ] && { echo "Usage: $0 <archive.tar.gz.gpg>"; exit 1; }
[ -f "$ARCHIVE" ] || { echo "ERROR: not found: $ARCHIVE"; exit 1; }
command -v gpg >/dev/null || { echo "ERROR: gpg not found (brew install gnupg)"; exit 1; }

STAGE="$(mktemp -d)"
BACKUP="$HOME/.secrets_backup/$(date +%Y%m%d_%H%M%S)"
cleanup() { rm -rf "$STAGE"; }
trap cleanup EXIT

echo "=== Importing secrets ==="
echo "Decrypting (passphrase from the export)..."
# See export-secrets.sh: loopback pinentry so gpg can prompt without a tty.
export GPG_TTY="${GPG_TTY:-$(tty 2>/dev/null)}"
gpg --decrypt --pinentry-mode loopback "$ARCHIVE" 2>/dev/null | tar xzf - -C "$STAGE" || {
  echo "ERROR: decryption failed — wrong passphrase or corrupt archive"; exit 1; }

[ -f "$STAGE/MANIFEST.txt" ] && { echo ""; cat "$STAGE/MANIFEST.txt"; echo ""; }

# back_up <path> — move an existing file/dir aside before overwriting.
back_up() {
  [ -e "$1" ] || return 0
  mkdir -p "$BACKUP"
  cp -R "$1" "$BACKUP/" 2>/dev/null && echo "  backed up: $1 -> $BACKUP/"
}

# --- SSH --------------------------------------------------------------------
if [ -d "$STAGE/ssh" ]; then
  back_up "$HOME/.ssh"
  mkdir -p "$HOME/.ssh"
  cp "$STAGE"/ssh/* "$HOME/.ssh/" 2>/dev/null
  chmod 700 "$HOME/.ssh"
  find "$HOME/.ssh" -maxdepth 1 -type f -exec chmod 600 {} \;
  find "$HOME/.ssh" -maxdepth 1 -name '*.pub' -exec chmod 644 {} \;
  [ -f "$HOME/.ssh/known_hosts" ] && chmod 644 "$HOME/.ssh/known_hosts"
  [ -f "$HOME/.ssh/config" ] && chmod 600 "$HOME/.ssh/config"
  echo "  ssh:    restored, permissions set"
fi

# --- AWS --------------------------------------------------------------------
if [ -d "$STAGE/aws" ]; then
  back_up "$HOME/.aws"
  mkdir -p "$HOME/.aws"
  cp "$STAGE"/aws/* "$HOME/.aws/" 2>/dev/null
  chmod 700 "$HOME/.aws"
  chmod 600 "$HOME/.aws"/* 2>/dev/null
  echo "  aws:    restored"
fi

# --- GPG --------------------------------------------------------------------
if [ -d "$STAGE/gnupg" ]; then
  mkdir -p "$HOME/.gnupg"; chmod 700 "$HOME/.gnupg"
  [ -f "$STAGE/gnupg/secret-keys.asc" ] && gpg --import "$STAGE/gnupg/secret-keys.asc" 2>&1 | sed 's/^/    /'
  [ -f "$STAGE/gnupg/public-keys.asc" ] && gpg --import "$STAGE/gnupg/public-keys.asc" 2>&1 | sed 's/^/    /'
  [ -f "$STAGE/gnupg/ownertrust.txt" ] && gpg --import-ownertrust "$STAGE/gnupg/ownertrust.txt" 2>&1 | sed 's/^/    /'
  echo "  gnupg:  imported"
fi

# --- Shell overrides --------------------------------------------------------
for f in .zshrc.local .gitconfig.local; do
  [ -f "$STAGE/$f" ] && { back_up "$HOME/$f"; cp "$STAGE/$f" "$HOME/$f"; echo "  $f: restored"; }
done

echo ""
echo "=== Done ==="
[ -d "$BACKUP" ] && echo "Previous files: $BACKUP"
echo ""
echo "Verify:"
echo "  ssh -T git@github.com"
echo "  ssh -T git@bitbucket.org        # needed for the nova repo"
echo "  aws sts get-caller-identity"
echo "  gpg --list-secret-keys"
echo ""
echo "Then re-authenticate what is not in this archive (keychain-backed):"
echo "  gh auth login && gcloud auth login && atuin login"
echo ""
echo "Finally, delete the archive from both machines:"
echo "  rm -P '$ARCHIVE'"

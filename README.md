# Dotfiles

macOS development environment, reproducible on a fresh machine.

## Provisioning a new Mac

```bash
git clone https://github.com/dandrade/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh --dry-run   # review
./bootstrap.sh
```

`bootstrap.sh` installs Xcode CLT, Homebrew, every package in the Brewfile,
symlinks the configs, and sets up the version managers. It is idempotent —
re-running it is the way to resume after a failure.

Three things it deliberately leaves to you, because they need your keys or
your judgement: secrets, repos, and plugin sync. It prints them when it ends.

## Layout

| Path | What |
|---|---|
| `zsh/` | `.zshrc`, `.zprofile`, `.zshenv` |
| `nvim/` | Neovim (LazyVim), pinned by `lazy-lock.json` |
| `tmux/`, `tmux-scripts/` | tmux config and helpers |
| `ghostty/` | Terminal config and shaders |
| `aerospace/`, `sketchybar/`, `skhd/` | Tiling WM, status bar, hotkeys |
| `starship/` | Prompt |
| `scripts/` | Migration and verification helpers |

| File | What |
|---|---|
| `Brewfile` | Curated package set — what a new machine needs |
| `Brewfile.optional` | Third-party taps and casks needing system approval |
| `Brewfile.full` | Full dump of the old machine, for reference only |
| `bootstrap.sh` | Provision a new machine |
| `install.sh` | Symlink configs into place |

## Scripts

```bash
./install.sh --dry-run          # preview symlinks
./install.sh                    # apply

./scripts/verify.sh --baseline  # on the OLD machine: snapshot it
./scripts/verify.sh             # on the NEW machine: compare

./scripts/export-secrets.sh     # OLD: encrypted archive of ssh/aws/gpg
./scripts/import-secrets.sh <f> # NEW: restore, with correct permissions
```

## Machine-specific config

`~/.zshrc.local` is sourced last and is git-ignored. Anything with a hardcoded
absolute path, per-machine tooling, or a secret belongs there — not in the
tracked `.zshrc`.

On a new machine this file starts empty, which is the point: if the setup only
works once you have filled it in, something that should be in the repo isn't.

## Conventions

- **The repo is the source of truth.** Configs are symlinks into it, so editing
  `~/.zshrc` *is* editing the repo. If a target turns back into a real file,
  the two will drift apart silently — `verify.sh` checks for exactly this.
- **The Brewfile must not lie.** It is derived from
  `brew leaves --installed-on-request`, not from a full dump. Verify with
  `brew bundle check --file=~/dotfiles/Brewfile --verbose`.
- **Installers append to `~/.zshrc`.** Since it is a symlink into the repo,
  check `git status` after running one and move anything machine-specific to
  `~/.zshrc.local`.
- **Secrets never get committed.** They move between machines through the
  encrypted archive from `export-secrets.sh`.

## Notes

- `zsh` is not in the Brewfile: macOS ships 5.9, the same version Homebrew has.
- `yarn` is not either — use `corepack enable`, bundled with Node.
- Homebrew 7 refuses untrusted third-party taps; `bootstrap.sh` runs
  `brew trust` before bundling.
- `install.sh` backs up anything it replaces to `~/.dotfiles_backup/<timestamp>/`.

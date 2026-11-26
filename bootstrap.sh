#!/usr/bin/env bash
# bootstrap.sh — idempotent setup for a fresh (or existing) MacBook.
# Safe to re-run anytime: every step checks before acting.
#
# Usage:  ./bootstrap.sh            # everything except macOS defaults
#         ./bootstrap.sh --macos    # also apply macOS defaults
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
APPLY_MACOS=false
[[ "${1:-}" == "--macos" ]] && APPLY_MACOS=true

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*"; }

[[ "$(uname -s)" == "Darwin" ]] || { echo "macOS only." >&2; exit 1; }
[[ "$(uname -m)" == "arm64" ]] || warn "Not Apple Silicon — paths assume /opt/homebrew."

# ── 0. Managed-device check ──────────────────────────────────
if profiles status -type enrollment 2>/dev/null | grep -qi "MDM enrollment: Yes"; then
  warn "This Mac is MDM-managed. Some casks (OrbStack, agent CLIs) may be blocked by policy."
fi

# ── 1. Xcode Command Line Tools ─────────────────────────────
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools (finish the dialog, then re-run this script)"
  xcode-select --install
  exit 0
fi

# ── 2. Homebrew ─────────────────────────────────────────────
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# ── 3. Packages ─────────────────────────────────────────────
log "Installing Brewfile packages"
brew bundle --file="$REPO_DIR/Brewfile"
if [[ -f "$REPO_DIR/Brewfile.local" ]]; then
  log "Installing Brewfile.local packages"
  brew bundle --file="$REPO_DIR/Brewfile.local"
fi

log "Installing Orca"
"$REPO_DIR/scripts/install-orca.sh"

# ── 4. Dotfiles (stow) ──────────────────────────────────────
log "Linking dotfiles"
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
mkdir -p "$HOME/.config"

# Back up any real file that would block a symlink.
while IFS= read -r -d '' src; do
  rel="${src#"$REPO_DIR/home/"}"
  dest="$HOME/$rel"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$dest" "$BACKUP_DIR/$rel"
    warn "Backed up existing $rel -> $BACKUP_DIR/$rel"
  fi
done < <(find "$REPO_DIR/home" -type f -print0)

stow --no-folding --restow --dir="$REPO_DIR" --target="$HOME" home

# ── 5. Machine-local git identity (never committed) ────────
if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  log "Creating ~/.gitconfig.local"
  read -r -p "  Git name:  " git_name
  read -r -p "  Git email: " git_email
  sed -e "s|__NAME__|$git_name|" -e "s|__EMAIL__|$git_email|" \
    "$REPO_DIR/templates/gitconfig.local.example" > "$HOME/.gitconfig.local"
  warn "Edit ~/.gitconfig.local to enable 1Password commit signing (see README)."
fi
[[ -f "$HOME/.zshrc.local" ]] || cp "$REPO_DIR/templates/zshrc.local.example" "$HOME/.zshrc.local"

# ── 6. Runtimes & agent CLIs (mise) ─────────────────────────
log "Installing runtimes and agent CLIs via mise"
mise install --yes

# ── 7. macOS defaults (opt-in) ──────────────────────────────
if $APPLY_MACOS; then
  log "Applying macOS defaults"
  "$REPO_DIR/scripts/macos-defaults.sh"
fi

log "Done. Run 'make doctor' to verify, then see README → 'Manual steps'."

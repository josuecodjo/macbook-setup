#!/usr/bin/env bash
# doctor.sh — verify the machine matches the repo. Exit non-zero on drift.
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0
ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$*"; fail=1; }

echo "Homebrew"
if brew bundle check --file="$REPO_DIR/Brewfile" >/dev/null 2>&1; then ok "Brewfile satisfied"
else bad "Brewfile drift — run: brew bundle check --verbose"; fi

echo "Dotfiles"
unlinked=0
while IFS= read -r -d '' src; do
  rel="${src#"$REPO_DIR/home/"}"
  if [[ -L "$HOME/$rel" && "$(readlink -f "$HOME/$rel")" == "$(readlink -f "$src")" ]]; then :
  else bad "$HOME/$rel not linked"; unlinked=1; fi
done < <(find "$REPO_DIR/home" -type f -print0)
[[ $unlinked -eq 0 ]] && ok "all dotfiles linked"

echo "Runtimes"
if mise ls --missing 2>/dev/null | grep -q .; then bad "mise tools missing — run: mise install"
else ok "mise tools installed"; fi

echo "Apps"
if [[ -d /Applications/Orca.app ]]; then ok "Orca"; else bad "Orca missing"; fi

echo "1Password SSH agent"
sock="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
if [[ -S "$sock" ]] && SSH_AUTH_SOCK="$sock" ssh-add -l >/dev/null 2>&1; then ok "agent up with keys"
else bad "agent not running or no keys (1Password → Settings → Developer)"; fi

echo "Git identity"
if git config --global user.email >/dev/null; then ok "$(git config --global user.email)"
else bad "no user.email — edit ~/.gitconfig.local"; fi

exit $fail

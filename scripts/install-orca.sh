#!/usr/bin/env bash
# install-orca.sh — install Orca (stablyai/orca), guarding against the
# unrelated plotly "orca" cask that has used the same Homebrew name.
set -euo pipefail

if [[ -d "/Applications/Orca.app" ]] && \
   ! defaults read "/Applications/Orca.app/Contents/Info" CFBundleIdentifier 2>/dev/null | grep -qi plotly; then
  echo "Orca already installed."
  exit 0
fi

homepage="$(brew info --cask --json=v2 orca 2>/dev/null | jq -r '.casks[0].homepage // empty' || true)"
if grep -qiE 'onorca|stablyai' <<<"$homepage"; then
  echo "Homebrew cask 'orca' is the right one ($homepage) — installing."
  brew install --cask orca
  exit 0
fi

echo "Homebrew cask 'orca' points to '${homepage:-nothing}' — falling back to GitHub release."
api="https://api.github.com/repos/stablyai/orca/releases/latest"
url="$(curl -fsSL "$api" | jq -r '
  [.assets[] | select(.name | test("\\.dmg$"))] as $dmgs
  | ([$dmgs[] | select(.name | test("arm64|aarch64|universal"; "i"))] + $dmgs)[0].browser_download_url // empty')"

if [[ -z "$url" ]]; then
  echo "Could not find a macOS .dmg. Install manually: https://onorca.dev/download" >&2
  exit 1
fi

tmp="$(mktemp -d)"
trap 'hdiutil detach "$tmp/mnt" -quiet 2>/dev/null || true; rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/orca.dmg" "$url"
hdiutil attach "$tmp/orca.dmg" -mountpoint "$tmp/mnt" -nobrowse -quiet
app="$(find "$tmp/mnt" -maxdepth 1 -name '*.app' | head -n1)"
[[ -n "$app" ]] || { echo "No .app in DMG." >&2; exit 1; }
cp -R "$app" /Applications/
echo "Installed $(basename "$app") from $url"

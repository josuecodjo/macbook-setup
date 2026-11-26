# Brewfile — the single source of truth for what's installed.
# Apply:   brew bundle --file=Brewfile
# Audit:   brew bundle check --file=Brewfile --verbose
# Machine-specific extras go in Brewfile.local (gitignored).
#
# NOTE: Orca is NOT listed here on purpose. The Homebrew cask named "orca"
# has historically pointed to plotly/orca (an unrelated Intel-only tool).
# scripts/install-orca.sh verifies the cask before using it.

tap "fluxcd/tap"

# ── Shell & core CLI ─────────────────────────────────────────
brew "git"
brew "stow"                    # symlinks home/ into ~
brew "mise"                    # per-project runtimes (Java, Node, Python) + agent CLIs
brew "starship"                # prompt (shows k8s context, red on prod)
brew "zoxide"                  # smarter cd
brew "fzf"
brew "ripgrep"
brew "fd"
brew "bat"
brew "eza"
brew "jq"
brew "yq"
brew "git-delta"
brew "lazygit"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "watch"
brew "tree"

# ── Forge ────────────────────────────────────────────────────
brew "glab"                    # GitLab CLI
brew "gh"                      # GitHub CLI (open-source work, Orca's PR integration)

# ── Kubernetes / GitOps ──────────────────────────────────────
brew "kubernetes-cli"
brew "helm"
brew "kustomize"
brew "k9s"
brew "kubectx"                 # kubectx + kubens
brew "stern"                   # multi-pod logs
brew "fluxcd/tap/flux"
brew "argocd"
brew "kubectl-radar"           # local k8s UI + MCP server for agents: `kubectl radar`
brew "opentofu"
brew "tflint"
brew "terraform-docs"
# terraform + terragrunt come from mise (per-project versions), not brew

# ── DevSecOps ────────────────────────────────────────────────
brew "trivy"
brew "grype"
brew "syft"
brew "cosign"
brew "gitleaks"
brew "hadolint"
brew "dive"
brew "shellcheck"
brew "shfmt"
brew "pre-commit"

# ── Apps ─────────────────────────────────────────────────────
cask "ghostty"                 # fast ad-hoc terminal (quick-terminal hotkey)
cask "orbstack"                # Docker + local Kubernetes, lighter than Docker Desktop
cask "multipass"               # Ubuntu VMs for the lab (mp, mpk, mps aliases)
cask "1password"
cask "1password-cli"
cask "raycast"
cask "visual-studio-code"
cask "font-jetbrains-mono-nerd-font"

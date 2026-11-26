# ~/.zshrc — managed by macbook-setup. Machine-specific stuff → ~/.zshrc.local

# ── History ─────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS
setopt AUTO_CD INTERACTIVE_COMMENTS

export EDITOR="vim"
export VISUAL="code --wait"

# ── 1Password SSH agent ─────────────────────────────────────
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# ── Kubernetes prod detection ───────────────────────────────
# Used by the kd*/kdn delete guards. Keep in sync with starship.toml.
export K8S_PROD_PATTERN="(prod|prd)"

# ── IaC ─────────────────────────────────────────────────────
# Terragrunt defaults to OpenTofu when tofu is installed; force Terraform.
# A repo can still override with `terraform_binary = "tofu"` in root.hcl.
export TG_TF_PATH="terraform"

# ── Completions ─────────────────────────────────────────────
FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions:$FPATH"
autoload -Uz compinit && compinit -C

# Cache slow completion generators; regenerate weekly.
_cache_completion() {
  local name=$1; shift
  local f="$HOME/.cache/zsh/_$name"
  if [[ ! -s $f || -n $(find "$f" -mtime +7 2>/dev/null) ]]; then
    mkdir -p "${f:h}" && "$@" >| "$f" 2>/dev/null
  fi
  source "$f"
}
(( $+commands[kubectl] )) && _cache_completion kubectl kubectl completion zsh
(( $+commands[flux] ))    && _cache_completion flux flux completion zsh
(( $+commands[helm] ))    && _cache_completion helm helm completion zsh
(( $+commands[glab] ))    && _cache_completion glab glab completion -s zsh
(( $+commands[argocd] ))  && _cache_completion argocd argocd completion zsh

# ── Tools ───────────────────────────────────────────────────
eval "$(mise activate zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
source <(fzf --zsh)
autoload -U +X bashcompinit && bashcompinit
(( $+commands[terraform] ))  && complete -o nospace -C terraform terraform
(( $+commands[terragrunt] )) && complete -o nospace -C terragrunt terragrunt
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# ── Aliases ─────────────────────────────────────────────────
source "$HOME/.config/zsh/aliases.zsh"

# ── Local overrides (not in git) ────────────────────────────
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Must be last
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

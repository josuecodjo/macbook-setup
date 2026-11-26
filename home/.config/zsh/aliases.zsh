# ~/.config/zsh/aliases.zsh — sourced by ~/.zshrc. Managed by macbook-setup.
# Ported from myLab/00-kubeSetup/scripts/starter.sh, adapted for macOS + zsh.

# ── Navigation / files ──────────────────────────────────────
alias ls='eza --group-directories-first'
alias ll='eza -la --git --group-directories-first'
alias lt='eza --tree --level=2'

# ── Git ─────────────────────────────────────────────────────
alias g='git'
alias lg='lazygit'
alias gs='git status -s'
alias gl='git branch -a'
alias gb='git checkout'
alias gnb='git checkout -b'
alias gac='git add . && git commit -m'
alias gp='git push origin $(git branch --show-current)'

# ── Docker (OrbStack) ───────────────────────────────────────
alias d='docker'
alias dstop='docker ps -q | xargs -r docker stop'   # no error when nothing is running
alias dclean='docker system prune -af'

# ── Kubernetes ──────────────────────────────────────────────
alias k='kubectl'
alias kx='kubectx'
alias kn='kubens'
alias ks='kubectl -n kube-system'
alias kdesc='kubectl describe'
alias kcf='kubectl create -f'
alias kaf='kubectl apply -f'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias klogs='kubectl logs -f'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias kgn='kubectl get nodes'

# Delete shortcuts are functions, not aliases: on a context that looks like
# prod (same pattern as the red starship prompt) they ask before deleting.
_k_prod_guard() {
  local ctx
  ctx="$(kubectl config current-context 2>/dev/null)"
  if [[ "$ctx" =~ ${K8S_PROD_PATTERN:-(prod|prd)} ]]; then
    print -P "%F{red}⚠  Context '$ctx' looks like PROD.%f kubectl delete $*"
    read -q "?Proceed? [y/N] " || { echo; return 1; }
    echo
  fi
}
kd()  { _k_prod_guard "$@"        && kubectl delete "$@"; }
kdp() { _k_prod_guard pod "$@"    && kubectl delete pod "$@"; }
kds() { _k_prod_guard svc "$@"    && kubectl delete svc "$@"; }
kdd() { _k_prod_guard deploy "$@" && kubectl delete deploy "$@"; }
kdn() { _k_prod_guard ns "$@"     && kubectl delete ns "$@"; }

# ── Argo CD ─────────────────────────────────────────────────
alias argo='argocd'
alias aal='argocd app list'
alias aag='argocd app get'
alias aad='argocd app diff'
alias aas='argocd app sync'
alias aah='argocd app history'
alias actx='argocd context'

# ── Flux ────────────────────────────────────────────────────
alias fga='flux get all -A'
alias fgk='flux get kustomizations -A'
alias fgh='flux get helmreleases -A'
alias frk='flux reconcile kustomization --with-source'

# ── Radar (Kubernetes UI, runs locally against your kubeconfig) ─
(( $+commands[radar] )) || alias radar='kubectl radar'

# ── Multipass ───────────────────────────────────────────────
alias mp='multipass'
alias mpk='multipass launch -n awx -c 2 -m 8G -d 20G noble'
alias mps='multipass shell'

# ── Python ──────────────────────────────────────────────────
alias venv='python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt'
alias activate='source .venv/bin/activate'

# ── Terraform / Terragrunt ──────────────────────────────────
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfv='terraform validate'
alias tff='terraform fmt -recursive'
alias tg='terragrunt'
alias tgp='terragrunt plan'
alias tga='terragrunt apply'
alias tgpa='terragrunt run --all plan'
alias tgf='terragrunt hcl fmt'

# ── Misc ────────────────────────────────────────────────────
scan() { trivy image --severity HIGH,CRITICAL --ignore-unfixed "$@"; }

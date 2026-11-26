# macbook-setup

My MacBook Pro set up as code. One command rebuilds the whole machine, and re-running it is safe.

```bash
xcode-select --install                      # fresh Mac only
git clone <this-repo> ~/macbook-setup && cd ~/macbook-setup
./bootstrap.sh --macos                      # drop --macos to skip system prefs
make doctor                                 # verify
```

## What you get

| Layer | Tools |
|---|---|
| Agent workspace | **Orca** (repos/worktrees), Claude Code, Codex, OpenCode (via mise) |
| Ad-hoc terminal | **Ghostty** with a drop-down quick terminal on `Cmd+`` |
| Containers / k8s | OrbStack, Multipass, kubectl, helm, kustomize, k9s, kubectx/kubens, stern, OpenTofu |
| GitOps | Flux, **Argo CD** CLI, **Radar** (`kubectl radar`: local cluster UI + MCP server for agents) |
| DevSecOps | trivy, grype, syft, cosign, gitleaks, hadolint, dive, shellcheck, pre-commit |
| Runtimes | mise → Java 21 (default), 17, 25 · Node LTS · Python 3.13 |
| IaC | mise → **Terraform**, **Terragrunt** (per-project versions) · OpenTofu, tflint, terraform-docs |
| Shell | zsh, starship (k8s context turns **red on prod**), zoxide, fzf, eza, bat, delta, lazygit |
| Secrets | 1Password SSH agent for SSH + commit signing; no keys on disk |

## Aliases

All in `home/.config/zsh/aliases.zsh` (ported from `myLab/starter.sh`). Highlights:

| Group | Aliases |
|---|---|
| Git | `gs` `gl` `gb` `gnb` `gac "msg"` `gp` `g` `lg` |
| Docker | `dstop` `dclean` `d` |
| kubectl | `k` `ks` `kgp` `kgpa` `kgs` `kgd` `kgn` `kdesc` `kaf` `kcf` `klogs` `kx` `kn` |
| Delete | `kd` `kdp` `kds` `kdd` `kdn`: **ask for confirmation on prod-looking contexts** |
| Argo CD | `argo` `aal` `aag` `aad` `aas` `aah` `actx` |
| Flux | `fga` `fgk` `fgh` `frk` |
| Terraform | `tf` `tfi` `tfp` `tfa` `tfv` `tff` |
| Terragrunt | `tg` `tgp` `tga` `tgpa` (run --all plan) `tgf` |
| Lab | `mp` `mpk` `mps` `venv` `activate` `radar` `scan <image>` |

## Layout

```
Brewfile                 packages (source of truth)
bootstrap.sh             idempotent installer
home/                    dotfiles, stow-linked into ~
scripts/install-orca.sh  installs Orca safely (see note)
scripts/macos-defaults.sh
scripts/doctor.sh        drift check
templates/               seeds for machine-local files
```

## Day-to-day

| | |
|---|---|
| `make update` | upgrade brew + mise tools |
| `make doctor` | does the machine still match the repo? |
| `make drift` | packages installed by hand that aren't in the Brewfile |
| `make link` | re-link dotfiles after editing `home/` |

Rule: if you install something by hand, either add it to `Brewfile` or remove it. `make drift` will catch it.

## What stays out of git

- `~/.gitconfig.local`: name, email, signing key (created on first run)
- `~/.zshrc.local`: proxy, client env vars
- `~/.ssh/config.local`: homelab and client hosts
- `Brewfile.local`: per-machine extras (e.g. personal vs CGI laptop)

## Manual steps (one time)

1. **1Password**: sign in → Settings → Developer → turn on *Use the SSH agent*. Add or generate your SSH key.
2. **Commit signing**: paste the public key into `~/.gitconfig.local` and uncomment the `[gpg]` block.
3. **OrbStack**: open it once to finish setup. Enable Kubernetes in its settings if you want a local cluster.
4. **Ghostty**: allow Accessibility permission so the global `Cmd+`` hotkey works.
5. **Raycast**: set it as your `Cmd+Space` launcher and disable the Spotlight shortcut.
6. **Agents**: run `claude`, `codex` and `opencode` once each to sign in. Then add repos in Orca.
7. **Radar + agents** (optional): start `kubectl radar`, then `claude mcp add --transport http radar http://localhost:9280/mcp-readonly` so Claude Code can read your cluster (read-only).
8. **Prod pattern**: set your real prod context names in two places: `context_pattern` in `home/.config/starship.toml` (red prompt) and `K8S_PROD_PATTERN` in `home/.zshrc` (delete guards).

## Notes

- **Terraform versions per repo**: run `mise use terraform@1.9.8` in a repo (writes `mise.toml`), or keep an existing `.terraform-version` and mise will pick it up. `TG_TF_PATH=terraform` makes Terragrunt call Terraform rather than OpenTofu.

- **Orca and Homebrew**: the Homebrew cask named `orca` has historically been *plotly/orca*, an unrelated tool. `install-orca.sh` checks the cask's homepage and falls back to the official GitHub release if it's the wrong one.
- **Managed laptops**: on an MDM-enrolled Mac, bootstrap prints a warning. Expect OrbStack or agent CLIs to be blocked by policy. Put work-only exceptions in `Brewfile.local`.
- **Agents via npm**: Claude Code, Codex and OpenCode are installed through mise's npm backend, so one `mise upgrade` keeps them all current.

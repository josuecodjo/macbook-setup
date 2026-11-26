.DEFAULT_GOAL := help
SHELL := /bin/bash
SCRIPTS := bootstrap.sh $(wildcard scripts/*.sh)

help: ## Show targets
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

install: ## Full setup (idempotent)
	./bootstrap.sh

macos: ## Apply macOS defaults
	./scripts/macos-defaults.sh

brew: ## Install/refresh Brewfile packages
	brew bundle --file=Brewfile
	@[ -f Brewfile.local ] && brew bundle --file=Brewfile.local || true

link: ## (Re)link dotfiles into ~
	stow --no-folding --restow --target=$(HOME) home

unlink: ## Remove dotfile symlinks
	stow --delete --target=$(HOME) home

update: ## Upgrade everything
	brew update && brew bundle --file=Brewfile --upgrade
	mise upgrade --yes

doctor: ## Check the machine matches the repo
	./scripts/doctor.sh

drift: ## Show installed packages not in Brewfile
	brew bundle cleanup --file=Brewfile

lint: ## Shellcheck all scripts
	shellcheck $(SCRIPTS)

.PHONY: help install macos brew link unlink update doctor drift lint

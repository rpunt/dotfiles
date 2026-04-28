# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Personal dotfiles for bash, zsh, and PowerShell. Shell configs are sourced (not symlinked for bash/zsh; symlinked for PowerShell). No build system or tests — just shell scripts.

## CI

CI runs markdownlint on push/PR to main. Lint config is in `.mdlrc`.

## Architecture

**Entry points:** `bashrc`, `zshrc`, `profile.ps1` — each sets `DOTFILES_DIR` and loads shared scripts.

**Loading order (bash/zsh):**

1. `~/.dotfiles_config` (optional early config, e.g. `SCM_PROVIDER="ado"`)
1. `scripts/common.sh` — detects OS, sources `os_{macos,linux}.sh`, then loads all `scripts/*.sh`
1. `scripts/path.sh` is loaded first (before other scripts)
1. `scripts/github.sh` vs `scripts/ado.sh` — only one is loaded, controlled by `SCM_PROVIDER` env var (defaults to `github`)
1. `~/.local_profile_overrides` (optional per-machine overrides, sourced last)

**PowerShell:** `profile.ps1` dot-sources all `scripts/*.ps1` files. PowerShell scripts (`*.ps1`) and shell scripts (`*.sh`) coexist in `scripts/` — some features have parallel implementations (e.g. `ado.sh`/`ado.ps1`, `oh-my-posh.sh`/`oh-my-posh.ps1`).

**Oh-My-Posh:** prompt theme is `rpunt.omp.json` (shared across all shells).

## Workflow Rules

- **Never commit to main.** Always create a feature branch first.

## Key Conventions

- Functions that need colored output call `colors()` from `misc.sh` first to set tput variables.
- PATH manipulation uses `prepend_path`/`append_path` helpers in `path.sh` for idempotent additions.
- 1Password CLI integration (`1password.sh`) provides `oplogin`, `getpassword`, `gettoken`, `getmfa` — used by `auth_gh_work`/`auth_gh_home` for GitHub auth switching.
- `ado.sh` functions are stubs (echoing "using ADO") — the GitHub equivalents in `github.sh` are the active implementations.

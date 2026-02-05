export DOTFILES_DIR="${DOTFILES_DIR:-${${(%):-%x}:A:h}}" # set DOTFILES_DIR to the directory of this file if not already set

# Load early config (e.g., SCM_PROVIDER="ado" for Azure DevOps laptops)
test -f ~/.dotfiles_config && source ~/.dotfiles_config

if [[ -f "${DOTFILES_DIR}/scripts/common.sh" ]]; then
  source "${DOTFILES_DIR}/scripts/common.sh"
fi

# Zsh-only behavior (completion, zle, etc.)
if [[ -n "$ZSH_VERSION" ]]; then
  if type brew &>/dev/null; then
    export BREW_PREFIX="$(brew --prefix)"
    eval "$(${BREW_PREFIX}/bin/brew shellenv)"
    FPATH="${BREW_PREFIX}/share/zsh/site-functions:${FPATH}"
  fi

  autoload bashcompinit && bashcompinit

  # case-insensitive completions
  autoload -Uz compinit && compinit

  zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

  # Lazy-load completions for faster startup
  if command -v op &>/dev/null; then
    eval "$(op completion zsh)"
    compdef _op op
  fi

  if [[ -n "$BREW_PREFIX" ]] && [[ -s "${BREW_PREFIX}/bin/aws_completer" ]]; then
    complete -C "${BREW_PREFIX}/bin/aws_completer" aws
  fi

  set -o vi # turn on VIM keybindings in zsh
  set -k    # set INTERACTIVE_COMMENTS (allow comments in pasted scripts without error)

fi

# place any private configs/overrides in ~/.local_profile_overrides
test -f ~/.local_profile_overrides && source ~/.local_profile_overrides

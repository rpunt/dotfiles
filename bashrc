# stop bash deprecation warnings
export BASH_SILENCE_DEPRECATION_WARNING=1

export DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# Load early config (e.g., SCM_PROVIDER="ado" for Azure DevOps laptops)
test -f ~/.dotfiles_config && source ~/.dotfiles_config

if type brew &>/dev/null; then
  export BREW_PREFIX="$(brew --prefix)"
  eval "$(brew shellenv)"
fi

# shellcheck source=/dev/null
if [[ -f "${DOTFILES_DIR}/scripts/common.sh" ]]; then
  source "${DOTFILES_DIR}/scripts/common.sh"
fi

# Anything bash-specific that truly can’t live in shared scripts:
if [[ -n "$BASH_VERSION" ]]; then

  set -o vi

  bind "set completion-ignore-case on"
  bind "set completion-map-case on"
  bind "set show-all-if-ambiguous on"

  # shopt -s autocd
  shopt -s cdspell
  shopt -s cdable_vars
fi

# place any private configs in ~/.local_profile_overrides
test -f ~/.local_profile_overrides && source ~/.local_profile_overrides

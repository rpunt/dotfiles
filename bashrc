# stop bash deprecation warnings
export BASH_SILENCE_DEPRECATION_WARNING=1

export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dev/dotfiles}"

# shellcheck source=/dev/null
if [[ -f "${DOTFILES_DIR}/scripts/common.sh" ]]; then
  source "${DOTFILES_DIR}/scripts/common.sh"
fi

# Anything bash-specific that truly can’t live in shared scripts:
if [[ -n "$BASH_VERSION" ]]; then
  if type brew &>/dev/null; then
    eval "$($(which brew) shellenv)"
  fi

  set -o vi

  if [ -n "$BASH_VERSION" ]; then
    bind "set completion-ignore-case on"
    bind "set completion-map-case on"
    bind "set show-all-if-ambiguous on"

    # shopt -s autocd
    shopt -s cdspell
    shopt -s cdable_vars
  fi

  # POSH_THEMES_PATH=$(brew --prefix oh-my-posh)/themes
  # eval "$(oh-my-posh completion bash)"
  # eval "$(oh-my-posh init bash --config "$POSH_THEMES_PATH"/clean-detailed.omp.json | sed 's|\[\[ -v MC_SID \]\]|[[ -n "$MC_SID" ]]|')"
fi

# place any private configs in ~/.local_profile_overrides
test -f ~/.local_profile_overrides && source ~/.local_profile_overrides

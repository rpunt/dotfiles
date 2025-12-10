export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dev/dotfiles}"

if [[ -f "${DOTFILES_DIR}/scripts/common.sh" ]]; then
  source "${DOTFILES_DIR}/scripts/common.sh"
fi

# Zsh-only behavior (completion, zle, etc.)
if [[ -n "$ZSH_VERSION" ]]; then
  if type brew &>/dev/null; then
    eval $(/opt/homebrew/bin/brew shellenv)
  fi

  autoload bashcompinit && bashcompinit

  # case-insensitive completions
  autoload -Uz compinit && compinit

  zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

  # 1password CLI completions
  eval "$(op completion zsh)"; compdef _op op

  [[ -s '/opt/homebrew/bin/aws_completer' ]] && complete -C '/opt/homebrew/bin/aws_completer' aws

  # load completions from Homebrew
  if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  fi

  set -o vi # turn on VIM keybindings in zsh
  set -k    # set INTERACTIVE_COMMENTS (allow comments in pasted scripts without error)

fi

# place any private configs in ~/.local_profile_overrides
test -f ~/.local_profile_overrides && source ~/.local_profile_overrides

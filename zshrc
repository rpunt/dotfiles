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

  # Cache completions for faster startup
  local cache_dir="${HOME}/.cache/zsh-completions"
  [[ -d "$cache_dir" ]] || mkdir -p "$cache_dir"
  for bin in op roachdev roachprod workload-analyzer workload-exporter; do
    if command -v "$bin" &>/dev/null; then
      local bin_path="$(command -v "$bin")"
      local cache_file="${cache_dir}/_${bin}"
      if [[ ! -f "$cache_file" || "$bin_path" -nt "$cache_file" ]]; then
        "$bin" completion zsh > "$cache_file" 2>/dev/null
      fi
      source "$cache_file"
      compdef "_${bin}" "$bin"
    fi
  done

  if [[ -n "$BREW_PREFIX" ]] && [[ -s "${BREW_PREFIX}/bin/aws_completer" ]]; then
    complete -C "${BREW_PREFIX}/bin/aws_completer" aws
  fi

  set -o vi # turn on VIM keybindings in zsh
  set -k    # set INTERACTIVE_COMMENTS (allow comments in pasted scripts without error)

fi

# place any private configs/overrides in ~/.local_profile_overrides
test -f ~/.local_profile_overrides && source ~/.local_profile_overrides

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

set -o vi

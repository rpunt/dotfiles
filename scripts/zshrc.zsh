autoload bashcompinit && bashcompinit
# case-insensitive completions
autoload -Uz compinit && compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# 1password CLI completions
eval "$(op completion zsh)"; compdef _op op

complete -C '/opt/homebrew/bin/aws_completer' aws

set -o vi

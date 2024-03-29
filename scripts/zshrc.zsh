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

# if os = MacOS
export SSH_AUTH_SOCK="${HOME}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
# don't forget these also:
# launchctl stop com.openssh.ssh-agent
# launchctl disable com.openssh.ssh-agent

set -o vi # turn on VIM keybindings in zsh
set -k    # set INTERACTIVE_COMMENTS (allow comments in pasted scripts without error)

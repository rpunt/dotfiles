set -o vi # turn on VIM keybindings in zsh
set -k    # set INTERACTIVE_COMMENTS (allow comments in pasted scripts without error)

eval "$(/opt/homebrew/bin/brew shellenv)"

# add gobins to PATH
export PATH="$PATH:$HOME/go/bin"

# add rancher to PATH
export PATH="$PATH:$HOME/.rd/bin"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

for file in $(ls ~/dev/dotfiles/scripts/*.zsh); do
  source $file
done

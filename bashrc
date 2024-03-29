# add gobins to PATH
export PATH="$PATH:$HOME/go/bin"

# add rancher to PATH
export PATH="$PATH:$HOME/.rd/bin"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

for file in $(ls ~/dev/dotfiles/scripts/*.sh); do
  source $file
done

if type brew &>/dev/null; then
  eval $(/opt/homebrew/bin/brew shellenv)
fi

for file in $(ls ~/dev/dotfiles/scripts/*.zsh); do
  source $file
done

# place any private configs in ~/.local_profile_overrides
test -f ~/.local_profile_overrides && source ~/.local_profile_overrides

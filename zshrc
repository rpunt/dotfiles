eval "$($(which brew) shellenv)"

for file in $(ls ~/dev/dotfiles/scripts/*.zsh); do
  source $file
done

# place any private configs in ~/.local_profile_overrides
test -f ~/.local_profile_overrides && source ~/.local_profile_overrides

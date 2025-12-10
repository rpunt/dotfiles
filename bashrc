eval "$($(which brew) shellenv)"

# Source path.sh first no matter what OS
source ~/dev/dotfiles/scripts/path.sh

# Source all others
for file in ~/dev/dotfiles/scripts/*.sh; do
  [[ "$file" == */path.sh ]] && continue
  source "$file"
done

# place any private configs in ~/.local_profile_overrides
test -f ~/.local_profile_overrides && source ~/.local_profile_overrides

eval "$($(which brew) shellenv)"

for file in $(ls ~/dev/dotfiles/scripts/*.zsh); do
  source $file
done

# place any private configs in ~/.local_profile_overrides
# if you can't use the 1password ssh-agent, include this bit in ~/.local_profile_overrides:
#
#ssh-add -l &>/dev/null
#if [ "$?" == 2 ]; then
#  test -r ~/.ssh-agent && \
#    eval "$(<~/.ssh-agent)" >/dev/null
#
#  ssh-add -l &>/dev/null
#  if [ "$?" == 2 ]; then
#    (umask 066; ssh-agent > ~/.ssh-agent)
#    eval "$(<~/.ssh-agent)" >/dev/null
#    ssh-add
#  fi
#fi
#
test -f ~/.local_profile_overrides && source ~/.local_profile_overrides

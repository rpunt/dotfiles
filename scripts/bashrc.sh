set -o vi

if [ ! -z "$BASH_VERSION" ]; then
  bind "set completion-ignore-case on"
  bind "set completion-map-case on"
  bind "set show-all-if-ambiguous on"

  # shopt -s autocd
  shopt -s cdspell
  shopt -s cdable_vars
fi

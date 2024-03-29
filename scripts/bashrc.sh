set -o vi

if [ -n "$BASH_VERSION" ]; then
  bind "set completion-ignore-case on"
  bind "set completion-map-case on"
  bind "set show-all-if-ambiguous on"

  # shopt -s autocd
  shopt -s cdspell
  shopt -s cdable_vars
fi

POSH_THEMES_PATH=$(brew --prefix oh-my-posh)/themes
eval "$(oh-my-posh completion bash)"
eval "$(oh-my-posh init bash --config "$POSH_THEMES_PATH"/clean-detailed.omp.json | sed 's|\[\[ -v MC_SID \]\]|[[ -n "$MC_SID" ]]|')"

# recommended font: https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip?WT.mc_id=-blog-scottha

DETECTED_SHELL="bash"
if [[ -n "$ZSH_VERSION" ]]; then
  DETECTED_SHELL="zsh"
fi

if type brew &>/dev/null; then
  POSH_THEMES_PATH=$(brew --prefix oh-my-posh)/themes
fi

eval "$(oh-my-posh init "$DETECTED_SHELL" --config "$HOME"/dev/dotfiles/rpunt.omp.json | sed 's|\[\[ -v MC_SID \]\]|[[ -n "$MC_SID" ]]|')"

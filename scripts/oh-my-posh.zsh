# recommended font: https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip?WT.mc_id=-blog-scottha

# a couple different themes to experiment with
#eval "$(oh-my-posh --init --shell bash --config /usr/local/opt/oh-my-posh/themes/agnoster.omp.json)"
#eval "$(oh-my-posh --init --shell bash --config /usr/local/Cellar/oh-my-posh/6.11.2/themes/jandedobbeleer.omp.json)"

autoload -Uz compinit
compinit

if type brew &>/dev/null; then
  POSH_THEMES_PATH=$(brew --prefix oh-my-posh)/themes
fi

#eval "$(oh-my-posh completion zsh)"
eval "$(oh-my-posh init zsh --config "$HOME"/dev/dotfiles/rpunt.omp.json)"

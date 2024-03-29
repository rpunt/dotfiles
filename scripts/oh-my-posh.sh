# recommended font: https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip?WT.mc_id=-blog-scottha

# a couple different themes to experiment with
#eval "$(oh-my-posh --init --shell bash --config /usr/local/opt/oh-my-posh/themes/agnoster.omp.json)"
#eval "$(oh-my-posh --init --shell bash --config /usr/local/Cellar/oh-my-posh/6.11.2/themes/jandedobbeleer.omp.json)"

# eval "$(oh-my-posh --init --shell bash --config "$HOME"/dev/dotfiles/rpunt.omp.json)"

POSH_THEMES_PATH=$(brew --prefix oh-my-posh)/themes
eval "$(oh-my-posh completion bash)"
eval "$(oh-my-posh init bash --config "$HOME"/dev/dotfiles/rpunt.omp.json | sed 's|\[\[ -v MC_SID \]\]|[[ -n "$MC_SID" ]]|')"

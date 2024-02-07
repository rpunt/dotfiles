alias ll="ls -l"
alias be="bundle exec"
alias kls="be kitchen list"
alias krm="be kitchen destroy"
alias kmk="be kitchen converge"
alias kv="be kitchen verify"

alias dbc='osascript $HOME/dev/dotfiles/scripts/setDefaultBrowser.scpt chrome'
alias dbf='osascript $HOME/dev/dotfiles/scripts/setDefaultBrowser.scpt firefox'
alias dbs='osascript $HOME/dev/dotfiles/scripts/setDefaultBrowser.scpt safari'

alias cr_start_single='cockroach start-single-node --store=/opt/homebrew/var/cockroach --http-port=26256 --insecure --host=localhost'

# still in beta
# alias copilot='gh copilot'
# alias cps='gh copilot suggest'
# alias cpe='gh copilot explain'

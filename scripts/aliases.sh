alias ll="ls -l"
alias be="bundle exec"
alias kls="be kitchen list"
alias krm="be kitchen destroy"
alias kmk="be kitchen converge"
alias kv="be kitchen verify"

bind "set completion-ignore-case on"
bind "set completion-map-case on"
bind "set show-all-if-ambiguous on"

set -o vi

# shopt -s autocd
shopt -s cdspell
shopt -s cdable_vars

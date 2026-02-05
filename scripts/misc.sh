# set vars for colorized shell outputs
# echo "${red}warning text${reset}"
function colors() {
  black=$(tput setaf 0)
  red=$(tput setaf 1)
  green=$(tput setaf 2)
  yellow=$(tput setaf 3)
  blue=$(tput setaf 4)
  magenta=$(tput setaf 5)
  cyan=$(tput setaf 6)
  white=$(tput setaf 7)
  reset=$(tput sgr0)
}

function superpull() {
  find . -type d -name '.git' -print0 | xargs -P 40 -n 1 -0 -I '{}' sh -c "cd \"{}\"/../ && pwd && git checkout master && git pull  && git fetch -p" \;
}

function joinStrings {
  local IFS="$1"; shift; echo "$*"
}

function weather() {
  curl wttr.in/"${1:-55328}"
}

# export ENABLE_FAST_GIT_PROMPT=0         # faster - don't use with ENABLE_GIT_PROMPT
# if [ "$ENABLE_FAST_GIT_PROMPT" = 1 ]; then
#   source "${HOME}/.git_bash_prompt"
# fi

function getaocinputs() {
  curl "https://adventofcode.com/$(date +%Y)/day/$(date +%-d)/input" --cookie "session=$(cat ~/.config/aoc/token)"
}

function sgrep() {
 grep -ir --exclude-dir="tfstate_backups" $1 | grep service_name
}

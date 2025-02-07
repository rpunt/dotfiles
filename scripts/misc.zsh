# stop bash deprecation warnings
export BASH_SILENCE_DEPRECATION_WARNING=1

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

prep_wal_failover() {
  local OPTIND o s c
  while getopts "s:c:" o; do
    case "${o}" in
      s)
          story="${OPTARG}"
          ;;
      c)
          cluster="${OPTARG}"
          ;;
      *)
          continue
          ;;
    esac
  done
  shift $((OPTIND-1))

  if [[ -z $story ]] || [[ -z $cluster ]]; then
    echo "prep_wal_failover [-c cluster] [-s story]";
    return 1
  fi

  git checkout master 1>/dev/null 2>&1
  git pull 1>/dev/null 2>&1

  STORY=$(echo $story | tr 'a-z' 'A-Z')
  TERRAFORM_FILE=$(egrep -lir --exclude-dir="tfstate_backups" "service_name\s+\=\s\"${cluster}\"" --include="crdb*.tf")
  if [ -z "$TERRAFORM_FILE" ]; then
    echo "No terraform file found for cluster $cluster"
    return 1
  fi
  if test "$(echo $TERRAFORM_FILE| wc -l)" -gt 1; then
    echo "too many files matched"
    return 1
  fi
  echo; echo "TERRAFORM_FILE: $TERRAFORM_FILE"; echo

  git branch -D "$STORY" 2>/dev/null
  git checkout -b "$STORY"

  PR_TEMPLATE=$(mktemp)
  echo -e "## What\nrepave ${cluster} for WAL failover\n\n## Why\nhttps://doordash.atlassian.net/browse/${STORY}" > $PR_TEMPLATE

  sed -i '' -e "s/source =.*/source = \"git::https:\/\/github.com\/doordash\/terraform-aws-crdb.git\/\/prod_cluster\?ref=v24.1.7_05\"/g" "$TERRAFORM_FILE"
  sed -i '' -e '/readonly_app_role.*=.*\[\]$/d' "$TERRAFORM_FILE"
  sed -i '' -e "/roles_user_sql.*=.*\[\]$/d" "$TERRAFORM_FILE"
  sed -i '' -e '/data_volumes_qty/a\
  enable_wal_failover = true' "$TERRAFORM_FILE"
  terraform fmt "$TERRAFORM_FILE"
  # if [[ $(git diff --shortstat) =~ "1 file changed.*2 insertions.*1 deletion" ]]
  # then
    git add "$TERRAFORM_FILE"
    git commit -m "repave $cluster for WAL failover ($STORY)"
    git push --set-upstream origin "$STORY"
    gh pr create -F $PR_TEMPLATE -t "repave $cluster for WAL failover ($STORY)"
    gh pr view --json url | jq -r .url | pbcopy
    echo; echo "PR URL copied to clipboard"; echo
  # else
  #   echo "Unexpected changeset"
  #   echo
  #   echo
  #   git diff
  # fi
  rm -f "$PR_TEMPLATE"
}

function merge_mine() {
  colors

  # PRS=($(gh pr list -A @me -L 100 --json number --jq '.[].number' | sort -r))
  PRS=($(gh pr list -A @me -L 100 --json number --jq '.[].number'))

  check_approved() {
    local pr=$1
    gh pr view $pr --json reviews --jq '.reviews | map(select(.state == "APPROVED")) | length'
  }

  check_checks() {
    local pr=$1
    gh pr checks $pr --required 1>/dev/null 2>&1
    # gh pr checks $pr 1>/dev/null 2>&1
    return $?
  }

  check_merge_state() {
    local pr=$1
    gh pr view $pr --json mergeStateStatus --jq '.mergeStateStatus'
  }

  for PR in "${PRS[@]}"; do
    local approved=0
    local mergeStateStatus="BEHIND"

    # this array syntax is specific to zsh
    if [ ${PRS[(ie)${PR}]} -gt 1 ]; then
      sleep 5
    fi
    approved=$(check_approved $PR)
    if [ "$approved" -lt 1 ]; then
      echo ${red}"PR $PR: is not approved${reset}"
      continue
    fi

    mergeStateStatus=$(check_merge_state $PR)
    if [[ "$mergeStateStatus" == "BEHIND" ]]; then
      echo ${red}"PR $PR: is ${mergeStateStatus}${reset}"
      echo "${cyan}PR $PR: updating branch${reset}"
      gh pr update-branch $PR
      sleep 8
      gh pr checks $PR --watch
    fi

    check_checks $PR
    if [ $? -ne 0 ]; then
      echo "${red}PR $PR: bad checks, skipping${reset}"
      continue
    fi

    echo "${green}PR $PR: applying${reset}"
    gh pr comment $PR -b 'atlantis apply'
    sleep 5
    gh pr checks $PR --watch
  done
}

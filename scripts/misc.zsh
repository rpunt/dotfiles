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

function prep_wal_failover() {
  local OPTIND o i c
  while getopts "i:c:e:" o; do
    case "${o}" in
      i)
          story="${OPTARG}"
          ;;
      c)
          cluster="${OPTARG}"
          ;;
      e)
          environment="${OPTARG}"
          ;;
      *)
          continue
          ;;
    esac
  done
  shift $((OPTIND-1))

  if [[ -z $story ]] || [[ -z $cluster ]] || [[ -z $environment ]]; then
    echo "prep_wal_failover [-e environment] [-c cluster] [-i issue]";
    return 1
  fi

  git checkout master 1>/dev/null 2>&1
  git pull 1>/dev/null 2>&1

  STORY=$(echo $story | tr 'a-z' 'A-Z')
  TERRAFORM_FILE=$(egrep -lir --exclude-dir="tfstate_backups" "service_name\s+\=\s\"${cluster}\"" --include="crdb*.tf")
  VERSION_FILE=$(dirname $TERRAFORM_FILE)/versions.tf
  if [[ "$environment" != "prod" && "$environment" != "staging" ]]; then
    echo "Invalid environment: $environment. Must be 'prod' or 'staging'."
    return 1
  fi
  if [ -z "$TERRAFORM_FILE" ]; then
    echo "No terraform file found for cluster $cluster"
    return 1
  fi
  if test "$(echo $TERRAFORM_FILE| wc -l)" -gt 1; then
    echo "too many files matched"
    return 1
  fi
  echo; echo "TERRAFORM_FILE: $TERRAFORM_FILE"; echo "VERSION_FILE: $VERSION_FILE"; echo

  git push -d origin "$STORY" 2>/dev/null
  git branch -D "$STORY" 2>/dev/null
  git checkout -b "$STORY"

  PR_TEMPLATE=$(mktemp)
  echo -e "## What\nrepave ${cluster}\n\n## Why\nhttps://doordash.atlassian.net/browse/${STORY}" > $PR_TEMPLATE

  sed -i '' -E "s/source[[:space:]]+=[[:space:]]+\"git.*/source = \"git::https:\/\/github.com\/doordash\/terraform-aws-crdb.git\/\/${environment}_cluster\?ref=v24.3.8_07\"/g" "$TERRAFORM_FILE"
  sed -i '' -E '/readonly_app_role[[:space:]]+=[[:space:]]+\[\]$/d' "$TERRAFORM_FILE"
  sed -i '' -E "/roles_user_sql[[:space:]]+=[[:space:]]+\[\]$/d" "$TERRAFORM_FILE"
  # sed -i '' -e "/db_object_owner.*$/d" "$TERRAFORM_FILE"
  # sed -i '' -e "/dba_login_suffixes.*$/d" "$TERRAFORM_FILE"
  sed -i '' -E "/enable_cpu_autoscale_policy[[:space:]]+=[[:space:]]+false$/d" "$TERRAFORM_FILE"
  sed -i '' -e "/enable_wal_failover.*$/d" "$TERRAFORM_FILE"
  sed -i '' -e '/data_volumes_qty/a\
  enable_wal_failover = true' "$TERRAFORM_FILE"
  terraform fmt "$TERRAFORM_FILE"
  echo -e 'terraform {\nrequired_version = ">= 1.9"\nrequired_providers {\naws = {\nsource = "hashicorp/aws"\nversion = "~> 5.0"\n}\n}\n}' >"$VERSION_FILE"
  terraform fmt "$VERSION_FILE"
  # if [[ $(git diff --shortstat) =~ "1 file changed.*2 insertions.*1 deletion" ]]
  # then
    git add "$TERRAFORM_FILE"
    git add "$VERSION_FILE"
    git commit -m "repave $cluster ($STORY)"
    git push --set-upstream origin "$STORY"
    gh pr create -F $PR_TEMPLATE -t "repave $cluster ($STORY)"
    gh pr view --json url | jq -r .url | pbcopy
    echo; echo "PR URL copied to clipboard"; echo
    pbpaste >>~/Desktop/my_pr.txt
  # else
  #   echo "Unexpected changeset"
  #   echo
  #   echo
  #   git diff
  # fi
  rm -f "$PR_TEMPLATE"
}

function check_pr_approved() {
  local approved_count=$(gh pr view $1 --json reviews --jq '.reviews | map(select(.state == "APPROVED")) | length')
  echo $approved_count
}

function check_pr_checks() {
  gh pr checks $1 --required 1>/dev/null 2>&1
  rc=$?
  return $rc
}

function check_pr_merge_state() {
  gh pr view $1 --json mergeStateStatus --jq '.mergeStateStatus'
}

function check_pr_is_merged() {
  gh pr view $1 --json state --jq '.state'
}

function merge_mine() {
  colors

  # Get a list of PR numbers assigned to the current user
  PRS=($(gh pr list -A @me -L 100 --json number --jq '.[].number' | sort))

  # Function to check if a PR is approved
  check_approved() {
    local approved_count=$(gh pr view $1 --json reviews --jq '.reviews | map(select(.state == "APPROVED")) | length')
    echo $approved_count
  }

  # Function to check if required checks have passed for a PR
  check_checks() {
    gh pr checks $1 --required 1>/dev/null 2>&1
    rc=$?
    return $rc
  }

  # Function to get the merge state of a PR
  check_merge_state() {
    gh pr view $1 --json mergeStateStatus --jq '.mergeStateStatus'
  }

  for PR in "${PRS[@]}"; do
    local approved=0
    local mergeStateStatus="INVALID"

    # Sleep if there are multiple PRs; if you've just merged one, GitHub might need a minute to catch up
    if [ ${#PRS[@]} -gt 1 ]; then
      sleep 5
    fi

    # Check if the PR is approved
    approved=$(check_approved $PR)
    if [ $approved -eq 0 ]; then
      echo "${red}PR $PR: is not approved${reset}"
      continue
    else
      echo "${green}PR $PR: approved${reset}"
    fi

    # Check the merge state of the PR
    while [[ "$mergeStateStatus" != "BLOCKED" ]]; do # "BLOCKED" means the PR is ready to merge, but prevented by rule
      if [[ "$mergeStateStatus" == "BEHIND" ]]; then
        echo -e "\t${cyan}updating branch${reset}"
        gh pr update-branch $PR
        sleep 8
        gh pr checks $PR --watch
      elif [[ "$mergeStateStatus" == "UNKNOWN" ]]; then
        echo -e "${cyan}replanning${reset}"
        gh pr comment $PR -b 'atlantis plan'
        sleep 8
        gh pr checks $PR --watch
      fi
      mergeStateStatus=$(check_merge_state $PR)
      echo "${cyan}PR $PR: mergeStateStatus is ${mergeStateStatus}${reset}"
    done

    # Check if required checks have passed
    if check_checks $PR; then
      echo "${green}PR $PR: checks passed${reset}"
    else
      echo "${red}PR $PR: bad checks, skipping${reset}"
      continue
    fi

    # Apply the PR
    echo "${green}PR $PR: applying${reset}"
    gh pr comment $PR -b 'atlantis apply'
    sleep 5
    gh pr checks $PR --watch
  done
}

function hammer_away() {
  colors

  PR=$1

  local merged=$(check_pr_is_merged $PR)
  while [[ "$merged" != "MERGED" ]]; do
    echo "${cyan}PR $PR: is ${merged}${reset}"
    # Check if the PR is approved
    approved=$(check_pr_approved $PR)
    if [ $approved -eq 0 ]; then
      echo "${red}PR $PR: is not approved${reset}"
      break
    else
      echo "${green}PR $PR: approved${reset}"
    fi

    # Check the merge state of the PR
    mergeStateStatus=$(check_pr_merge_state $PR)
    echo "${cyan}PR $PR: mergeStateStatus is ${mergeStateStatus}${reset}"
    # while [[ "$mergeStateStatus" != "BLOCKED" ]]; do # "BLOCKED" means the PR is ready to merge, but prevented by rule
    if [[ "$mergeStateStatus" == "BEHIND" ]]; then
      echo -e "\t${cyan}updating branch${reset}"
      gh pr update-branch $PR
      sleep 8
      gh pr checks $PR --watch
      continue
    elif [[ "$mergeStateStatus" == "UNKNOWN" ]]; then
      echo -e "${cyan}replanning${reset}"
      gh pr comment $PR -b 'atlantis plan'
      sleep 8
      gh pr checks $PR --watch
      continue
    fi

    # Check if required checks have passed
    if check_pr_checks $PR; then
      echo "${green}PR $PR: checks passed${reset}"
    else
      echo "${red}PR $PR: bad checks, skipping${reset}"
      break
    fi

    # Apply the PR
    echo "${green}PR $PR: applying${reset}"
    gh pr comment $PR -b 'atlantis apply'
    sleep 5
    gh pr checks $PR --watch

    merged=$(check_pr_is_merged $PR)
  done
  echo "${cyan}PR $PR: is ${merged}${reset}"
}

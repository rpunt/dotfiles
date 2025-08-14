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

function check_pr_approved() {
  if [ -z "$1" ]; then
    echo "Error: PR number is required" >&2
    return 1
  fi

  # Check if PR exists first
  if ! gh pr view "$1" &>/dev/null; then
    echo "Error: PR #$1 not found" >&2
    return 1
  fi

  local approved_count=$(gh pr view "$1" --json reviews --jq '.reviews | map(select(.state == "APPROVED")) | length')
  echo $approved_count
}

function check_pr_approvers() {
  if [ -z "$1" ]; then
    echo "Error: PR number is required" >&2
    return 1
  fi

  gh pr view "$1" --json reviews --jq '.reviews | map(select(.state == "APPROVED")) | .[].author.login' 2>/dev/null
}

function check_pr_checks() {
  if [ -z "$1" ]; then
    echo "Error: PR number is required" >&2
    return 1
  fi

  # Check if PR exists first
  if ! gh pr view "$1" &>/dev/null; then
    echo "Error: PR #$1 not found" >&2
    return 1
  fi

  gh pr checks "$1" --required 1>/dev/null 2>&1
  rc=$?
  return $rc
}

function check_pr_failed_checks() {
  if [ -z "$1" ]; then
    echo "Error: PR number is required" >&2
    return 1
  fi

  gh pr view "$1" --json statusCheckRollup --jq '.statusCheckRollup[] | select(.state != "SUCCESS" and .state != null) | {context: .context, state: .state, targetUrl: .targetUrl}'
}

function check_pr_merge_state() {
  if [ -z "$1" ]; then
    echo "Error: PR number is required" >&2
    return 1
  fi

  gh pr view "$1" --json mergeStateStatus --jq '.mergeStateStatus'
}

function check_pr_is_merged() {
  gh pr view $1 --json state --jq '.state'
}

function merge_mine() {
  colors

  # Get a list of PR numbers assigned to the current user (excluding drafts)
  PRS=($(gh pr list -A @me -L 100 --json number,isDraft --jq '.[] | select(.isDraft == false) | .number' | sort))

  if [ ${#PRS[@]} -eq 0 ]; then
    echo "${yellow}No PRs found assigned to you${reset}"
    return 0
  fi

  echo "${cyan}Found ${#PRS[@]} PRs to process${reset}"

  for PR in "${PRS[@]}"; do
    local approved=0
    local mergeStateStatus="INVALID"

    # Sleep if there are multiple PRs; if you've just merged one, GitHub might need a minute to catch up
    if [ ${#PRS[@]} -gt 1 ]; then
      sleep 5
    fi

    echo "${cyan}Processing PR $PR${reset}"

    # Check if the PR is approved
    approved=$(check_pr_approved $PR)
    if [ $approved -eq 0 ]; then
      echo "${red}PR $PR: is not approved${reset}"
      continue
    else
      echo "${green}PR $PR: approved with $approved approval(s)${reset}"
    fi

    # Process the PR until it's in BLOCKED state or we hit an error
    local max_attempts=10
    local attempt=1

    while [[ $attempt -le $max_attempts ]]; do
      mergeStateStatus=$(check_pr_merge_state $PR)
      echo "${cyan}PR $PR: mergeStateStatus is ${mergeStateStatus}${reset}"

      if [[ "$mergeStateStatus" == "BLOCKED" ]]; then
        # BLOCKED means the PR is ready to merge, but prevented by rule (which is what we want)

        # Check if we're blocked by pullapprove
        failed_checks=$(check_pr_failed_checks $PR)
        if [ -n "$failed_checks" ] && echo "$failed_checks" | jq -e 'select(.context == "pullapprove" and .state == "PENDING")' > /dev/null; then
          echo "${yellow}    - Waiting on human approval via pullapprove, skipping${reset}"
          continue 2
        fi

        break
      elif [[ "$mergeStateStatus" == "BEHIND" ]]; then
        echo -e "\t${cyan}updating branch${reset}"
        if ! gh pr update-branch $PR; then
          echo "${red}Failed to update branch for PR $PR${reset}"
          continue 2
        fi
        sleep 8
        gh pr checks $PR --watch
      elif [[ "$mergeStateStatus" == "UNKNOWN" ]]; then
        echo -e "\t${cyan}replanning${reset}"
        gh pr comment $PR -b 'atlantis plan'
        sleep 8
        gh pr checks $PR --watch
      elif [[ "$mergeStateStatus" == "DIRTY" || "$mergeStateStatus" == "UNSTABLE" ]]; then
        echo "${red}PR $PR: merge state is $mergeStateStatus, skipping${reset}"
        continue 2
      else
        echo "${yellow}PR $PR: unhandled merge state $mergeStateStatus, trying again${reset}"
      fi

      ((attempt++))

      if [[ $attempt -gt $max_attempts ]]; then
        echo "${red}PR $PR: exceeded maximum attempts, skipping${reset}"
        continue 2
      fi
    done

    # Check if required checks have passed
    if check_pr_checks $PR; then
      echo "${green}PR $PR: checks passed${reset}"
    else
      echo "${red}PR $PR: bad checks, details:${reset}"
      failed_checks=$(check_pr_failed_checks $PR)
      if [ -n "$failed_checks" ]; then
        # Check if we're waiting on pullapprove
        if echo "$failed_checks" | jq -e 'select(.context == "pullapprove" and .state == "PENDING")' > /dev/null; then
          echo "${yellow}    - Waiting on human approval via pullapprove, skipping${reset}"
          continue
        fi

        # Display all failed checks
        echo "$failed_checks" | jq -r '. | "    - \(.context): \(.state) (\(.targetUrl))"' | while read -r line; do
          echo -e "${red}$line${reset}"
        done
      else
        echo "${red}    - No details available${reset}"
      fi
      continue
    fi

    # Apply the PR
    echo "${green}PR $PR: applying${reset}"
    gh pr comment $PR -b 'atlantis apply'
    sleep 5
    gh pr checks $PR --watch

    echo "${green}PR $PR: processing complete${reset}"
  done

  echo "${green}All PRs processed${reset}"
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
      echo "${red}PR $PR: bad checks, details:${reset}"
      failed_checks=$(check_pr_failed_checks $PR)
      if [ -n "$failed_checks" ]; then
        # Check if we're waiting on pullapprove
        if echo "$failed_checks" | jq -e 'select(.context == "pullapprove" and .state == "PENDING")' > /dev/null; then
          echo "${yellow}    - Waiting on human approval via pullapprove, breaking${reset}"
          break
        fi

        # Display all failed checks
        echo "$failed_checks" | jq -r '. | "    - \(.context): \(.state) (\(.targetUrl))"' | while read -r line; do
          echo -e "${red}$line${reset}"
        done
      else
        echo "${red}    - No details available${reset}"
      fi
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

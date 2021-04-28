#!/bin/bash

# stop bash deprecation warnings
export BASH_SILENCE_DEPRECATION_WARNING=1

function superpull() {
  find . -type d -name '.git' -print0 | xargs -P 40 -n 1 -0 -I '{}' sh -c "cd \"{}\"/../ && pwd && git checkout master && git pull  && git fetch -p" \;
}

function joinStrings {
  local IFS="$1"; shift; echo "$*"
}

function weather() {
  curl wttr.in/${1:-55328}
}

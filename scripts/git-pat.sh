#!/bin/bash
# This file is only sourced if SCM_PROVIDER=ado, so it can assume Azure DevOps-specific logic without checking SCM_PROVIDER again.
git_pat() {
  if [ $# -eq 0 ]; then
    command git
    return
  fi

  if [ -z "${_GIT_PAT_CACHE:-}" ]; then
    read -rsp "Enter ADO PAT: " _GIT_PAT_CACHE </dev/tty
    echo >/dev/tty
  fi

  local _HEADER_VALUE
  _HEADER_VALUE="$(printf 'Authorization: Basic %s' "$(printf ':%s' "$_GIT_PAT_CACHE" | base64 | tr -d '\n')")"

  HEADER_VALUE="$_HEADER_VALUE" \
    command git --config-env=http.extraheader=HEADER_VALUE "$@"
}

git_pat_clear() {
  unset _GIT_PAT_CACHE
}

alias git='git_pat'

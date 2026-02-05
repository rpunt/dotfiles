# scripts/common.sh
# Shared loader for bash/zsh

# DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/dev/dotfiles}"
# export DOTFILES_DIR

# Detect OS
case "$(uname -s)" in
  Darwin) OS_TYPE="macos" ;;
  Linux)  OS_TYPE="linux" ;;
  *)      OS_TYPE="unknown" ;;
esac
export OS_TYPE

[[ -f "${DOTFILES_DIR}/scripts/os_${OS_TYPE}.sh" ]] && source "${DOTFILES_DIR}/scripts/os_${OS_TYPE}.sh"

# 1. PATH always first
# shellcheck source=/dev/null
source "${DOTFILES_DIR}/scripts/path.sh"

# 2. Source all other *.sh in a controlled way
for file in "${DOTFILES_DIR}"/scripts/*.sh; do
  # Skip path.sh (already sourced)
  [[ "$file" == */path.sh ]] && continue
  # Skip this loader itself if you put it under scripts/
  [[ "$file" == */common.sh ]] && continue
  # Skip the os-specific loader
  [[ "$file" == */os_${OS_TYPE}.sh ]] && continue

  # Skip SCM providers based on SCM_PROVIDER env var (default: github)
  # Set SCM_PROVIDER="ado" in ~/.dotfiles_config for Azure DevOps, if appropriate
  if [[ "$file" == */github.sh ]] && [[ "${SCM_PROVIDER:-github}" != "github" ]]; then
    continue
  fi
  if [[ "$file" == */ado.sh ]] && [[ "${SCM_PROVIDER:-github}" != "ado" ]]; then
    continue
  fi

  [[ -f "$file" ]] || continue
  [[ -r "$file" ]] || continue

  # shellcheck source=/dev/null
  source "$file"
done

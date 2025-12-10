# Idempotent helpers
prepend_path() {
  case ":$PATH:" in
    *":$1:"*) ;; # already present
    *) PATH="$1:$PATH" ;;
  esac
}

append_path() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$PATH:$1" ;;
  esac
}

# Base
prepend_path "${HOME}/bin"
prepend_path "${HOME}/.local/bin"

# Go
if [[ -d "${HOME}/go/bin" ]]; then
  append_path "${HOME}/go/bin"
fi

if [[ -d "${HOME}/.cargo/bin" ]]; then
  append_path "${HOME}/.cargo/bin"
fi

if [[ -d "$HOME/.asdf/shims" ]]; then
  append_path "$HOME/.asdf/shims"
fi

# work-internal: ensure tooling available
if [[ -d "$HOME/go/src/github.com/cockroachdb/cockroach/bin" ]]; then
  append_path "$HOME/go/src/github.com/cockroachdb/cockroach/bin"
fi

# OS-specific path bits
case "${OS_TYPE:-}" in
  macos)
    # e.g. Homebrew
    if [[ -d "/opt/homebrew/bin" ]]; then
      prepend_path "/opt/homebrew/bin"
    elif [[ -d "/usr/local/bin" ]]; then
      prepend_path "/usr/local/bin"
    fi
    ;;
  linux)
    # Maybe /snap/bin or distro-specific paths
    if [[ -d "/snap/bin" ]]; then
      append_path "/snap/bin"
    fi
    ;;
esac

# scripts/rust.sh

# Load rustup environment if present
if [[ -f "${HOME}/.cargo/env" ]]; then
  # shellcheck source=/dev/null
  source "${HOME}/.cargo/env"
fi

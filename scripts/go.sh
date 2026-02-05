export GOPATH=~/go
if [[ -n "$BREW_PREFIX" ]]; then
  export GOROOT="${BREW_PREFIX}/opt/go/libexec"
elif type brew &>/dev/null; then
  export GOROOT="$(brew --prefix go)/libexec"
fi

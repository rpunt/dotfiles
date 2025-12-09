export GOPATH=~/go
if type brew &>/dev/null; then
  export GOROOT="$(brew --prefix go)/libexec"
fi
